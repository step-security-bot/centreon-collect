/*
** Copyright 2011 Merethis
**
** This file is part of Centreon Engine.
**
** Centreon Engine is free software: you can redistribute it and/or
** modify it under the terms of the GNU General Public License version 2
** as published by the Free Software Foundation.
**
** Centreon Engine is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Centreon Engine. If not, see
** <http://www.gnu.org/licenses/>.
*/

#include "globals.hh"
#include "skiplist.hh"
#include "logging/logger.hh"
#include "objects/utils.hh"
#include "objects/contactsmember.hh"
#include "objects/contactgroupsmember.hh"
#include "objects/contactgroup.hh"
#include "objects/contact.hh"
#include "objects/hostescalation.hh"

using namespace com::centreon::engine;
using namespace com::centreon::engine::logging;
using namespace com::centreon::engine::objects::utils;

/**
 *  Wrapper C
 *
 *  @see com::centreon::engine::objects::link
 */
bool link_hostescalation(hostescalation* obj,
                         contact** contacts,
                         contactgroup** contactgroups,
                         timeperiod* escalation_period) {
  try {
    objects::link(obj,
                  tab2qvec(contacts),
                  tab2qvec(contactgroups),
                  escalation_period);
  }
  catch (std::exception const& e) {
    logger(log_runtime_error, basic) << e.what();
    return (false);
  }
  catch (...) {
    logger(log_runtime_error, basic) << Q_FUNC_INFO << " unknow exception.";
    return (false);
  }
  return (true);
}

/**
 *  Wrapper C
 *
 *  @see com::centreon::engine::objects::release
 */
void release_hostescalation(hostescalation const* obj) {
  try {
    objects::release(obj);
  }
  catch (std::exception const& e) {
    logger(log_runtime_error, basic) << e.what();
  }
  catch (...) {
    logger(log_runtime_error, basic) << Q_FUNC_INFO << " unknow exception.";
  }
}

/**
 *  Link an host escalation with hostgroups, contacts, contactgroups and
 *  escalation period into the engine.
 *
 *  @param[in,out] obj               Object to link with a correct name.
 *  @param[in]     contacts          Set host contacts.
 *  @param[in]     contactgroups     Set host contactgroups.
 *  @param[in]     escalation_period Set host escalation period.
 */
void objects::link(hostescalation* obj,
                   QVector<contact*> const& contacts,
                   QVector<contactgroup*> const& contactgroups,
                   timeperiod* escalation_period) {
  // check object contents.
  if (obj == NULL)
    throw (engine_error() << "hostescalation is a NULL pointer.");
  if (obj->host_name == NULL)
    throw (engine_error() << "hostescalation invalid host name.");

  // check all arguments and set default option for optional options.
  if (contacts.isEmpty() == true && contactgroups.isEmpty() == true)
    throw (engine_error() << "hostescalation '" << obj->host_name
           << "' no contact or no contact groups are defined.");

  if ((obj->host_ptr = find_host(obj->host_name)) == NULL)
    throw (engine_error() << "hostescalation '" << obj->host_name << "' invalid host.");

  if (add_contactgroups_to_object(contactgroups, &obj->contact_groups) == false)
    throw (engine_error() << "hostescalation '" << obj->host_name << "' invalid contactgroups.");

  if (add_contacts_to_object(contacts, &obj->contacts) == false)
    throw (engine_error() << "hostescalation '" << obj->host_name << "' invalid contacts.");

  obj->escalation_period_ptr = escalation_period;
}

/**
 *  Cleanup memory of hostescalation.
 *
 *  @param[in] obj The hostescalation to cleanup memory.
 */
void objects::release(hostescalation const* obj) {
  if (obj == NULL)
    return;

  contactgroupsmember const* cgmember = obj->contact_groups;
  while ((cgmember = release(cgmember)));

  contactsmember const* cntctmember = obj->contacts;
  while ((cntctmember = release(cntctmember)));

  skiplist_delete(object_skiplists[HOSTESCALATION_SKIPLIST], obj);
  remove_object_list(obj, &hostescalation_list, &hostescalation_list_tail);

  // host_ptr not free.
  // escalation_period_ptr not free.

  delete[] obj->host_name;
  delete[] obj->escalation_period;
  delete obj;
}
