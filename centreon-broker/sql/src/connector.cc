/*
** Copyright 2011-2012 Merethis
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

#include "com/centreon/broker/sql/connector.hh"
#include "com/centreon/broker/sql/stream.hh"

using namespace com::centreon::broker;
using namespace com::centreon::broker::sql;

/**************************************
*                                     *
*           Public Methods            *
*                                     *
**************************************/

/**
 *  Default constructor.
 */
connector::connector() : io::endpoint(false) {}

/**
 *  Copy constructor.
 *
 *  @param[in] c Object to copy.
 */
connector::connector(connector const& c)
  : io::endpoint(c),
    _db(c._db),
    _host(c._host),
    _password(c._password),
    _port(c._port),
    _queries_per_transaction(0),
    _type(c._type),
    _user(c._user),
    _with_state_events(c._with_state_events) {}

/**
 *  Destructor.
 */
connector::~connector() {}

/**
 *  Assignment operator.
 *
 *  @param[in] c Object to copy.
 *
 *  @return This object.
 */
connector& connector::operator=(connector const& c) {
  io::endpoint::operator=(c);
  _db = c._db;
  _host = c._host;
  _password = c._password;
  _port = c._port;
  _queries_per_transaction = c._queries_per_transaction;
  _type = c._type;
  _user = c._user;
  _with_state_events = c._with_state_events;
  return (*this);
}

/**
 *  Close the connector.
 */
void connector::close() {
  return ;
}

/**
 *  Set connection parameters.
 *
 *  @param[in] type                    Database type.
 *  @param[in] host                    Database host.
 *  @param[in] port                    Database port.
 *  @param[in] user                    User.
 *  @param[in] password                Password.
 *  @param[in] db                      Database name.
 *  @param[in] queries_per_transaction Queries per transaction.
 *  @param[in] with_state_events       Enable state events ?
 */
void connector::connect_to(
                  QString const& type,
                  QString const& host,
                  unsigned short port,
                  QString const& user,
                  QString const& password,
                  QString const& db,
                  unsigned int queries_per_transaction,
                  bool with_state_events) {
  _db = db;
  _host = host;
  _password = password;
  _port = port;
  _queries_per_transaction = queries_per_transaction;
  _type = type;
  _user = user;
  _with_state_events = with_state_events;
  return ;
}

/**
 *  Connect to a DB.
 *
 *  @return SQL connection object.
 */
misc::shared_ptr<io::stream> connector::open() {
  return (misc::shared_ptr<io::stream>(new stream(
                                             _type,
                                             _host,
                                             _port,
                                             _user,
                                             _password,
                                             _db,
                                             _queries_per_transaction,
                                             _with_state_events)));
}
