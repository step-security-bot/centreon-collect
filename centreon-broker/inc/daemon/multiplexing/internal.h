/*
**  Copyright 2009 MERETHIS
**  This file is part of CentreonBroker.
**
**  CentreonBroker is free software: you can redistribute it and/or modify it
**  under the terms of the GNU General Public License as published by the Free
**  Software Foundation, either version 2 of the License, or (at your option)
**  any later version.
**
**  CentreonBroker is distributed in the hope that it will be useful, but
**  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
**  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
**  for more details.
**
**  You should have received a copy of the GNU General Public License along
**  with CentreonBroker.  If not, see <http://www.gnu.org/licenses/>.
**
**  For more information : contact@centreon.com
*/

#ifndef MULTIPLEXING_INTERNAL_H_
# define MULTIPLEXING_INTERNAL_H_

# include <list>
# include <map>
# include <string>
# include <utility>
# include "concurrency/mutex.h"

namespace                       Multiplexing
{
  // Forward declaration.
  class                         Subscriber;

  // List of hosts.
  extern std::map<std::pair<std::string, std::string>, int>
                                gl_hosts;
  extern Concurrency::Mutex     gl_hostsm;

  // List of services.
  extern std::map<std::pair<std::pair<std::string, std::string>, std::string>,
                  int>
                                gl_services;
  extern Concurrency::Mutex     gl_servicesm;

  // Internal multiplexing variables.
  extern std::list<Subscriber*> gl_subscribers;
  extern Concurrency::Mutex     gl_subscribersm;
}

#endif /* !MULTIPLEXING_INTERNAL_H_ */
