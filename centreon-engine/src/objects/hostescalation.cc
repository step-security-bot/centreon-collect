/*
** Copyright 2011-2013 Merethis
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

#include "com/centreon/engine/misc/object.hh"
#include "com/centreon/engine/misc/string.hh"
#include "com/centreon/engine/objects/hostescalation.hh"

using namespace com::centreon::engine::misc;

/**
 *  Equal operator.
 *
 *  @param[in] obj1 The first object to compare.
 *  @param[in] obj2 The second object to compare.
 *
 *  @return True if is the same object, otherwise false.
 */
bool operator==(
       hostescalation const& obj1,
       hostescalation const& obj2) throw () {
  return (false);
}

/**
 *  Not equal operator.
 *
 *  @param[in] obj1 The first object to compare.
 *  @param[in] obj2 The second object to compare.
 *
 *  @return True if is not the same object, otherwise false.
 */
bool operator!=(
       hostescalation const& obj1,
       hostescalation const& obj2) throw () {
  return (!operator==(obj1, obj2));
}

/**
 *  Dump hostescalation content into the stream.
 *
 *  @param[out] os  The output stream.
 *  @param[in]  obj The hostescalation to dump.
 *
 *  @return The output stream.
 */
std::ostream& operator<<(std::ostream& os, hostescalation const& obj) {
  os << "hostescalation {\n"
    "  host_name:               " << chkstr(obj.host_name) << "\n"
    "  first_notification:      " << obj.first_notification << "\n"
    "  last_notification:       " << obj.last_notification << "\n"
    "  notification_interval:   " << obj.notification_interval << "\n"
    "  escalation_period:       " << chkstr(obj.escalation_period) << "\n"
    "  escalate_on_recovery:    " << obj.escalate_on_recovery << "\n"
    "  escalate_on_down:        " << obj.escalate_on_down << "\n"
    "  escalate_on_unreachable: " << obj.escalate_on_unreachable << "\n"
    "  contact_groups:          " << chkobj(os, obj.contact_groups) << "\n"
    "  contacts:                " << chkobj(os, obj.contacts) << "\n"
    "  host_ptr:                " << obj.host_ptr << "\n"
    "  escalation_period_ptr:   " << obj.escalation_period_ptr << "\n"
    "}\n";
  return (os);
}

