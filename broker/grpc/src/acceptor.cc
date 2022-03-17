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

#include "grpc_stream.grpc.pb.h"

#include "com/centreon/broker/grpc/acceptor.hh"
#include "com/centreon/broker/grpc/server.hh"

using namespace com::centreon::broker;
using namespace com::centreon::broker::grpc;

acceptor::acceptor(const grpc_config::pointer& conf)
    : io::endpoint(true), _grpc_instance(server::create(conf)) {}

acceptor::~acceptor() {}

std::unique_ptr<io::stream> acceptor::open() {
  return _grpc_instance->open(system_clock::now() + std::chrono::seconds(3));
}

std::unique_ptr<io::stream> acceptor::open(
    const system_clock::time_point& dead_line) {
  return _grpc_instance->open(dead_line);
}

bool acceptor::is_ready() const {
  return _grpc_instance->is_ready();
}