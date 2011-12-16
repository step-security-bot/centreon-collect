/*
** Copyright 2011 Merethis
**
** This file is part of Centreon Clib.
**
** Centreon Clib is free software: you can redistribute it
** and/or modify it under the terms of the GNU Affero General Public
** License as published by the Free Software Foundation, either version
** 3 of the License, or (at your option) any later version.
**
** Centreon Clib is distributed in the hope that it will be
** useful, but WITHOUT ANY WARRANTY; without even the implied warranty
** of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** Affero General Public License for more details.
**
** You should have received a copy of the GNU Affero General Public
** License along with Centreon Clib. If not, see
** <http://www.gnu.org/licenses/>.
*/

#include <iostream>
#include <string>
#include "com/centreon/exception/basic.hh"
#include "com/centreon/misc/argument.hh"

using namespace com::centreon::misc;

/**
 *  Check the set long name.
 *
 *  @return 0 on success.
 */
int main() {
  try {
    std::string long_name("help");
    argument arg;
    arg.set_long_name(long_name);
    if (arg.get_long_name() != long_name)
      throw (basic_error() << "invalid long name");
  }
  catch (std::exception const& e) {
    std::cerr << "error: " << e.what() << std::endl;
    return (1);
  }
  return (0);
}
