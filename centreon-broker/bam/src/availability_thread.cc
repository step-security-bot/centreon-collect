/*
** Copyright 2014 Merethis
**
** This file is part of Centreon Broker.
**
** Centreon Broker is free software: you can redistribute it and/or
** modify it under the terms of the GNU General Public License version 2
** as published by the Free Software Foundation.
**
** Centreon Broker is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Centreon Broker. If not, see
** <http://www.gnu.org/licenses/>.
*/

#include <ctime>
#include <QMutexLocker>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <sstream>
#include "com/centreon/broker/bam/availability_thread.hh"
#include "com/centreon/broker/exceptions/msg.hh"
#include "com/centreon/broker/logging/logging.hh"
#include "com/centreon/broker/misc/global_lock.hh"

using namespace com::centreon::broker;
using namespace com::centreon::broker::bam;

/**
 *  Constructor.
 *
 *  @param[in] db_type      BAM DB type.
 *  @param[in] db_host      BAM DB host.
 *  @param[in] db_port      BAM DB port.
 *  @param[in] db_user      BAM DB user.
 *  @param[in] db_password  BAM DB password.
 *  @param[in] db_name      BAM DB name.
 */
availability_thread::availability_thread(
                       QString const& db_type,
                       QString const& db_host,
                       unsigned short db_port,
                       QString const& db_user,
                       QString const& db_password,
                       QString const& db_name)
  : _db_type(db_type),
    _db_host(db_host),
    _db_port(db_port),
    _db_user(db_user),
    _db_password(db_password),
    _db_name(db_name),
    _mutex(QMutex::Recursive),
    _should_exit(false),
    _should_rebuild_all(false) {}

/**
 *  Destructor.
 */
availability_thread::~availability_thread() {
  _close_database();
}

/**
 *  The main loop of thread.
 */
void availability_thread::run() {
  // Open the DB

  // Lock the mutex.
  _mutex.lock();

  // Check for termination asked.
  if (_should_exit) {
    _mutex.unlock();
    return ;
  }

  while (true) {
    try {
      // Calculate the duration until next midnight.
      time_t midnight;
      _compute_next_midnight(midnight);
      unsigned long wait_for = std::difftime(midnight, ::time(NULL));
      _wait.wait(&_mutex, wait_for * 1000);

      // Termination asked.
      if (_should_exit)
        break ;

      // Open the database.
      _open_database();

      _build_availabilities(midnight, _should_rebuild_all);
      _should_rebuild_all = false;
      _bas_to_rebuild.clear();

      // Close the database.
      _close_database();
      } catch (std::exception const& e) {
      logging::error(logging::medium) << e.what();
      _close_database();
    }
  }

  // Unlock the mutex.
  _mutex.unlock();
}

/**
 *  Ask for the thread termination.
 */
void availability_thread::terminate() {
  QMutexLocker lock(&_mutex);
  _should_exit = true;
  _wait.wakeOne();
}

/**
 *  Clear the timeperiods registered in the availability thread.
 */
void availability_thread::clear_timeperiods() {
  QMutexLocker lock(&_mutex);
  _timeperiods.clear();
}

/**
 *  Register a timeperiod in the availability thread.
 *
 *  @param[in] tp  The timeperiod.
 */
void availability_thread::register_timeperiod(time::timeperiod::ptr tp) {
  QMutexLocker lock(&_mutex);
  _timeperiods[tp->get_id()] = tp;
}

/**
 *  Ask the thread to rebuild the availabilities.
 */
void availability_thread::rebuild_availabilities(
    std::vector<unsigned int> const& bas_to_rebuild) {
  QMutexLocker lock(&_mutex);
  _should_rebuild_all = true;
  _bas_to_rebuild.insert(bas_to_rebuild.begin(), bas_to_rebuild.end());
  _wait.wakeOne();
}

/**
 *  Delete all the availabilities.
 */
void availability_thread::_delete_all_availabilities() {
  if (_bas_to_rebuild.empty())
    return ;

  // Prepare the query.
  std::stringstream str;
  str << "DELETE * FROM mod_bam_reporting_ba_availabilities WHERE ba_id IN (";
  for (std::set<unsigned int>::const_iterator it(_bas_to_rebuild.begin()),
                                              end(_bas_to_rebuild.end());
       it != end;
       ++it)
    str << *it << ", ";
  std::string query = str.str();
  query.erase(query.begin() + query.find_last_of(','), query.end());
  query.append(")");

  QSqlQuery q(*_db);
  q.setForwardOnly(true);
  if (!q.exec(query.c_str()))
    throw (exceptions::msg()
           << "BAM-BI: Availability thread could not delete the "
              "BA availabilities from the reporting database: "
           << q.lastError().text());
}

/**
 *  @brief  Build all the availabilities.
 *
 *  This is called from the context of the availability thread.
 *
 *  @param[in] mignight   Midnight of today.
 *  @param[in] build_all  True if we should rebuild everything.
 */
void availability_thread::_build_availabilities(time_t midnight,
                                                bool build_all) {
  time_t first_day = 0;
  QSqlQuery q(*_db);
  q.setForwardOnly(true);
  std::stringstream query;

  // Get the first day of rebuilding. If a complete rebuilding was asked,
  // it's the day of the chronogically first event.
  // If not, it's the day following the chronogically last availability.
  if (build_all) {
    query << "SELECT min(start_time)"
             "  FROM mod_bam_reporting_ba_events_durations";
    if (!q.exec(query.str().c_str()) || !q.next())
      throw (exceptions::msg()
             << "BAM-BI: Availability thread could not select the BA durations "
                "from the reporting database: " << q.lastError().text());

    first_day = q.value(0).toInt();
    _compute_start_of_day(first_day, first_day);
    q.next();
    _delete_all_availabilities();
  }
  else {
    query << "SELECT max(time_id)"
             "  FROM mod_bam_reporting_ba_availabilities";
    if (!q.exec(query.str().c_str()) || !q.next())
      throw (exceptions::msg()
             << "BAM-BI: Availability thread "
                "could not select the BA availabilities "
                "from the reporting database: " << q.lastError().text());

    first_day = q.value(0).toInt();
    first_day += (3600 * 24);
    q.next();
  }

  // Write the availabilities day after day.
  for (; first_day < midnight; first_day += (3600*24))
    _build_daily_availabilities(q, first_day, first_day + (3600 * 24));
}

/**
 *  @brief  Build all the availabilities of a day.
 *
 *  This is called from the context of the availability thread.
 *
 *  @param[in] q         A SQL query object.
 *  @param[in] day_start The start of the day.
 *  @param[in] day_end   The end of the day.
 */
void availability_thread::_build_daily_availabilities(
                            QSqlQuery& q,
                            time_t day_start,
                            time_t day_end) {
  std::stringstream query;
  query << "SELECT a.ba_event_id, b.ba_id, a.start_time, a.end_time,"
           "       a.duration, a.sla_duration, a.timeperiod_id,"
           "       a.timeperiod_is_default, b.status, b.in_downtime"
           "  FROM mod_bam_reporting_ba_events_durations AS a"
           "    INNER JOIN mod_bam_reporting_ba_events AS b"
        << "  WHERE a.start_time >= " << day_start
        << "    OR (a.end_time >= " << day_start << "a.end_time < " << day_end
        << "       )";
  if (!q.exec(query.str().c_str()))
    throw (exceptions::msg()
           << "BAM-BI: the availability thread could not build the data: "
            << q.lastError().text());

  // Create a builder for each ba_id and associated timeperiod_id.
  std::map<std::pair<unsigned int, unsigned int>,
            availability_builder> builders;
  while (q.next()) {
    unsigned int ba_id = q.value(1).toInt();
    unsigned int timeperiod_id = q.value(6).toInt();
    // Find the timeperiod.
    std::map<unsigned int,
              time::timeperiod::ptr>::const_iterator tp
        = _timeperiods.find(timeperiod_id);
    // No timeperiod found, skip.
    if (tp == _timeperiods.end())
      continue ;
    // Find the builder.
    std::map<std::pair<unsigned int, unsigned int>,
              availability_builder>::iterator found
        = builders.find(std::make_pair(ba_id, timeperiod_id));
    // No builders found, create one.
    if (found == builders.end())
      found = builders.insert(std::make_pair(
                                std::make_pair(ba_id, timeperiod_id),
                                availability_builder(day_end, day_start))).first;
    // Add the event to the builder.
    found->second.add_event(
      q.value(8).toInt(), // Status
      q.value(2).toInt(), // Start time
      q.value(3).toInt(), // End time
      q.value(9).toBool(), // Was in downtime
      tp->second);
    // Add the timeperiod is default flag.
    found->second.set_timeperiod_is_default(q.value(7).toBool());
  }

  // For each builder, write the availabilities.
  for (std::map<std::pair<unsigned int, unsigned int>,
                availability_builder>::const_iterator
         it = builders.begin(),
         end = builders.end();
       it != end;
       ++it)
    _write_availability(q, it->second, it->first.first, day_start, it->first.second);
}

/**
 *  Write an availability to the database.
 *
 *  @param[in] q                      A QSqlQuery connected to this database.
 *  @param[in] builder                The builder of an availability.
 *  @param[in] ba_id                  The id of the ba.
 *  @param[in] day_start              The start of the day.
 *  @param[in] timeperiod_id          The id of the timeperiod.
 */
void availability_thread::_write_availability(QSqlQuery& q,
                                              availability_builder const& builder,
                                              unsigned int ba_id,
                                              time_t day_start,
                                              unsigned int timeperiod_id) {
  std::stringstream query;
  query << "INSERT INTO mod_bam_reporting_ba_availabilities "
        << "  (ba_id, time_id, timeperiod_id, timeperiod_is_default,"
           "   available, unavailable, degraded,"
           "   unknown, downtime, alert_unavailable_opened,"
           "   alert_degraded_opened, alert_unknown_opened,"
           "   alert_downtime_opened)"
           "  VALUES (" << ba_id << ", " << day_start << ", "
        << timeperiod_id << ", " << builder.get_timeperiod_is_default() << ", "
        << builder.get_available() << ", " << builder.get_unavailable()
        << ", " << builder.get_degraded() << ", " << builder.get_unknown()
        << ", " << builder.get_unavailable_opened() << ", "
        << builder.get_degraded_opened() << ", " << builder.get_unknown_opened()
        << ", " << builder.get_downtime_opened() << ")";
  if (!q.exec(query.str().c_str()))
    return ;
}

/**
 *  Compute the next midnight.
 *
 *  @param[out] res  The next midnight.
 */
void availability_thread::_compute_next_midnight(time_t& res) {
  _compute_start_of_day(::time(NULL), res);
  res += (24 * 3600);
}

/**
 *  Get the start of the day of the timestamp when.
 *
 *  @param[in] when  The timestamp.
 *  @param[out] res  The result.
 */
void availability_thread::_compute_start_of_day(
                            time_t when,
                            time_t& res) {
  struct tm tmv;
  if (!localtime_r(&when, &tmv))
    throw (exceptions::msg()
           << "BAM-BI: Availability thread could not compute start of day.");
  tmv.tm_sec = 1;
  tmv.tm_min = tmv.tm_hour = 0;
  res = mktime(&tmv);
}

/**
 *  Open the database.
 */
void availability_thread::_open_database() {
  // Availability thread connection ID.
  QString bam_id;
  bam_id.setNum((qulonglong)this, 16);

  // Add database connection.
  _db.reset(
        new QSqlDatabase(QSqlDatabase::addDatabase(
                                         _db_type,
                                         bam_id)));
  // Set DB parameters.
  _db->setHostName(_db_host);
  _db->setPort(_db_port);
  _db->setUserName(_db_user);
  _db->setPassword(_db_password);
  _db->setDatabaseName(_db_name);

  // Open database.
  if (!_db->open())
    throw (exceptions::msg()
           << "BAM-BI: Availability thread could not connect to "
              "reporting database '"
           << _db_name << "' on host '" << _db_host
           << ":" << _db_port << "': " << _db->lastError().text());
}

/**
 *  Close the database.
 */
void availability_thread::_close_database() {
  QString bam_id;
  bam_id.setNum((qulonglong)this, 16);
  QSqlDatabase::removeDatabase(bam_id);
  _db.reset();
}
