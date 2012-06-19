/*
** Copyright 2011-2012 Merethis
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

#include <cstdlib>
#include <exception>
#include <iostream>
#include "com/centreon/engine/error.hh"
#include "com/centreon/engine/macros.hh"
#include "test/objects/create_object.hh"
#include "test/objects/release.hh"

using namespace test::objects;

/**
 *  Check that timeperiod exclusion can be released properly.
 *
 *  @return EXIT_SUCCESS on success.
 */
int main() {
  try {
    // Tests.
    release_null_pointer(static_cast<timeperiodexclusion const*>(NULL));
    release_objects(&create_timeperiodexclusion);
    release_objects(&create_timeperiodexclusion, 10);
  }
  catch (std::exception const& e) {
    // Exception handling.
    std::cerr << "error: " << e.what() << std::endl;
    free_memory(get_global_macros());
    return (EXIT_FAILURE);
  }

  return (EXIT_SUCCESS);
}
