/*
 * Copyright 2022 Centreon (https://www.centreon.com/)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * For more information : contact@centreon.com
 *
 */

#include <gtest/gtest.h>

#include "com/centreon/connector/ssh/namespace.hh"
#include "com/centreon/connector/ssh/orders/options.hh"

using namespace com::centreon::connector::orders;

TEST(SSHOptions, cmdline_bad_port) {
  // Base object.
  std::string cmd("toto -p 1234567");
  std::unique_ptr<options> opt;
  ASSERT_THROW(std::make_unique<options>(cmd), std::exception);
}

TEST(SSHOptions, cmdline_bad_port_negative) {
  // Base object.
  std::string cmd("toto -p -123");
  std::unique_ptr<options> opt;
  ASSERT_THROW(std::make_unique<options>(cmd), std::exception);
}

TEST(SSHOptions, cmdline_good_port) {
  // Base object.
  std::string cmd("toto -p 14567");
  std::unique_ptr<options> opt;
  ASSERT_NO_THROW(std::make_unique<options>(cmd));
}
