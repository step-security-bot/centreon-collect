/*
** Copyright 2013 Merethis
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

#include <sstream>
#include "com/centreon/broker/neb/internal.hh"
#include "com/centreon/broker/neb/statistics/hosts_checked.hh"
#include "com/centreon/engine/globals.hh"

using namespace com::centreon::broker::neb;
using namespace com::centreon::broker::neb::statistics;

/**
 *  Default constructor.
 */
hosts_checked::hosts_checked()
  : plugin("hosts_checked") {}

/**
 *  Copy constructor.
 *
 *  @param[in] right Object to copy.
 */
hosts_checked::hosts_checked(hosts_checked const& right)
 : plugin(right) {

}

/**
 *  Destructor.
 */
hosts_checked::~hosts_checked() {}

/**
 *  Assignment operator.
 *
 *  @param[in] right Object to copy.
 *
 *  @return This object.
 */
hosts_checked& hosts_checked::operator=(hosts_checked const& right) {
  plugin::operator=(right);
  return (*this);
}

/**
 *  Get statistics.
 *
 *  @param[out] output   The output return by the plugin.
 *  @param[out] perfdata The perf data return by the plugin.
 */
void hosts_checked::run(
              std::string& output,
	      std::string& perfdata) {
  // Count hosts checked.
  unsigned int total(0);
  for (host* h(host_list); h; h = h->next)
    if (h->has_been_checked)
      ++total;

  // Output.
  std::ostringstream oss;
  oss << "Engine " << instance_name.toStdString()
      << " has " << total << " checked hosts";
  output = oss.str();

  // Perfdata.
  oss.str("");
  oss << "hosts_checked=" << total;
  perfdata = oss.str();

  return ;
}