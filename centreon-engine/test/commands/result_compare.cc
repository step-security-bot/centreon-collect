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

#include <exception>
#include <QCoreApplication>
#include "com/centreon/engine/commands/result.hh"
#include "com/centreon/engine/error.hh"
#include "com/centreon/timestamp.hh"
#include "test/unittest.hh"

using namespace com::centreon::engine;
using namespace com::centreon::engine::commands;

#define DEFAULT_ID      42
#define DEFAULT_STDOUT  "stdout string test"
#define DEFAULT_STDERR  "stderr string test"
#define DEFAULT_RETURN  0
#define DEFAULT_TIMEOUT true
#define DEFAULT_EXIT_OK false

/**
 *  Check the comparison operator.
 */
int main_test() {
  // Prepare.
  com::centreon::timestamp now(com::centreon::timestamp::now());
  result res(
           DEFAULT_ID,
           DEFAULT_STDOUT,
           DEFAULT_STDERR,
           now,
           now,
           DEFAULT_RETURN,
           DEFAULT_TIMEOUT,
           DEFAULT_EXIT_OK);

  // Tests.
  if (!(res == res))
    throw (engine_error() << "error: operator== failed");
  if (res != res)
    throw (engine_error() << "error: operator!= failed");

  return (0);
}

/**
 *  Init unit test.
 */
int main(int argc, char** argv) {
  QCoreApplication app(argc, argv);
  unittest utest(&main_test);
  QObject::connect(&utest, SIGNAL(finished()), &app, SLOT(quit()));
  utest.start();
  app.exec();
  return (utest.ret());
}
