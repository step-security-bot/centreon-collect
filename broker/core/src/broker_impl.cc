/*
 * Copyright 2020-2021 Centreon (https://www.centreon.com/)
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

#include "com/centreon/broker/broker_impl.hh"

#include "com/centreon/broker/config/applier/endpoint.hh"
#include "com/centreon/broker/config/applier/state.hh"
#include "com/centreon/broker/log_v2.hh"
#include "com/centreon/broker/multiplexing/publisher.hh"
#include "com/centreon/broker/stats/center.hh"
#include "com/centreon/broker/stats/helper.hh"
#include "com/centreon/broker/version.hh"

using namespace com::centreon::broker;
using namespace com::centreon::broker::version;

/**
 * @brief Return the Broker's version.
 *
 * @param context gRPC context
 * @param  unused
 * @param response A Version object to fill
 *
 * @return Status::OK
 */
grpc::Status broker_impl::GetVersion(grpc::ServerContext* context
                                     __attribute__((unused)),
                                     const ::google::protobuf::Empty* request
                                     __attribute__((unused)),
                                     Version* response) {
  response->set_major(major);
  response->set_minor(minor);
  response->set_patch(patch);
  return grpc::Status::OK;
}

grpc::Status broker_impl::GetNumModules(grpc::ServerContext* context
                                        __attribute__((unused)),
                                        const ::google::protobuf::Empty*,
                                        GenericSize* response) {
  auto& mod_applier(config::applier::state::instance().get_modules());

  std::lock_guard<std::mutex> lock(mod_applier.module_mutex());
  response->set_size(std::distance(mod_applier.begin(), mod_applier.end()));

  return grpc::Status::OK;
}

grpc::Status broker_impl::GetNumEndpoint(grpc::ServerContext* context
                                         __attribute__((unused)),
                                         const ::google::protobuf::Empty*,
                                         GenericSize* response) {
  // Endpoint applier.
  config::applier::endpoint& endp_applier(
      config::applier::endpoint::instance());

  std::lock_guard<std::timed_mutex> lock(endp_applier.endpoints_mutex());
  response->set_size(std::distance(endp_applier.endpoints_begin(),
                                   endp_applier.endpoints_end()));

  return grpc::Status::OK;
}

grpc::Status broker_impl::GetModulesStats(grpc::ServerContext* context
                                          __attribute__((unused)),
                                          const GenericNameOrIndex* request,
                                          GenericString* response) {
  std::vector<nlohmann::json> value;
  stats::get_loaded_module_stats(value);

  bool found{false};
  nlohmann::json object;
  switch (request->nameOrIndex_case()) {
    case GenericNameOrIndex::NAMEORINDEX_NOT_SET:
      for (auto& obj : value) {
        object["module" + obj["name"].get<std::string>()] = obj;
      }
      response->set_str_arg(object.dump());
      break;

    case GenericNameOrIndex::kStr:
      for (auto& obj : value) {
        if (obj["name"].get<std::string>() == request->str()) {
          found = true;
          response->set_str_arg(object.dump());
          break;
        }
      }
      if (!found)
        return grpc::Status(grpc::INVALID_ARGUMENT,
                            grpc::string("name not found"));

      break;

    case GenericNameOrIndex::kIdx:

      if (request->idx() + 1 > value.size())
        return grpc::Status(grpc::INVALID_ARGUMENT,
                            grpc::string("idx too big"));

      object = value[request->idx()];
      response->set_str_arg(object.dump());
      break;

    default:
      return grpc::Status::CANCELLED;
      break;
  }

  return grpc::Status::OK;
}

grpc::Status broker_impl::GetEndpointStats(grpc::ServerContext* context
                                           __attribute__((unused)),
                                           const GenericNameOrIndex* request,
                                           GenericString* response) {
  std::vector<nlohmann::json> value;
  try {
    if (!stats::get_endpoint_stats(value))
      return grpc::Status(grpc::UNAVAILABLE, grpc::string("endpoint locked"));
  } catch (...) {
    return grpc::Status(grpc::ABORTED, grpc::string("endpoint throw error"));
  }

  bool found{false};
  nlohmann::json object;

  switch (request->nameOrIndex_case()) {
    case GenericNameOrIndex::NAMEORINDEX_NOT_SET:
      for (auto& obj : value) {
        object["module" + obj["name"].get<std::string>()] = obj;
      }
      response->set_str_arg(object.dump());
      break;

    case GenericNameOrIndex::kStr:
      for (auto& obj : value) {
        if (obj["name"].get<std::string>() == request->str()) {
          found = true;
          response->set_str_arg(obj.dump());
          break;
        }
      }
      if (!found)
        return grpc::Status(grpc::INVALID_ARGUMENT,
                            grpc::string("name not found"));
      break;

    case GenericNameOrIndex::kIdx:

      if ((request->idx() + 1) > value.size())
        return grpc::Status(grpc::INVALID_ARGUMENT,
                            grpc::string("idx too big"));

      object = value[request->idx()];
      response->set_str_arg(object.dump());
      break;

    default:
      return grpc::Status::CANCELLED;
      break;
  }
  return grpc::Status::OK;
}

grpc::Status broker_impl::GetGenericStats(
    grpc::ServerContext* context __attribute__((unused)),
    const ::google::protobuf::Empty* request __attribute__((unused)),
    GenericString* response) {
  nlohmann::json object;
  stats::get_generic_stats(object);

  response->set_str_arg(object.dump());
  return grpc::Status::OK;
}

grpc::Status broker_impl::GetSqlManagerStats(
    grpc::ServerContext* context __attribute__((unused)),
    const ::google::protobuf::Empty* request __attribute__((unused)),
    SqlManagerStats* response) {
  stats::center::instance().get_sql_manager_stats(response);
  return grpc::Status::OK;
}

grpc::Status broker_impl::GetConflictManagerStats(
    grpc::ServerContext* context __attribute__((unused)),
    const ::google::protobuf::Empty* request __attribute__((unused)),
    ConflictManagerStats* response) {
  stats::center::instance().get_conflict_manager_stats(response);
  return grpc::Status::OK;
}

grpc::Status broker_impl::GetMuxerStats(grpc::ServerContext* context
                                        __attribute__((unused)),
                                        const GenericString* request,
                                        MuxerStats* response) {
  const std::string name = request->str_arg();
  bool status = stats::center::instance().muxer_stats(name, response);
  return status ? grpc::Status::OK
                : grpc::Status(
                      grpc::StatusCode::NOT_FOUND,
                      fmt::format("no muxer stats found for name '{}'", name));
}

void broker_impl::set_broker_name(const std::string& s) {
  _broker_name = s;
}

/**
 * @brief The internal part of the gRPC RebuildMetrics() function.
 *
 * @param context (unused)
 * @param request A pointer to a MetricIds which contains a vector of metric
 * ids. These ids correspond to the metrics to rebuild.
 * @param response (unused)
 *
 * @return grpc::Status::OK
 */
grpc::Status broker_impl::RebuildRRDGraphs(grpc::ServerContext* context
                                           __attribute__((unused)),
                                           const IndexIds* request,
                                           ::google::protobuf::Empty* response
                                           __attribute__((unused))) {
  multiplexing::publisher pblshr;
  auto e{std::make_shared<bbdo::pb_rebuild_rrd_graphs>(*request)};
  pblshr.write(e);
  return grpc::Status::OK;
}

grpc::Status broker_impl::RemoveGraphs(grpc::ServerContext* context
                                       __attribute__((unused)),
                                       const ToRemove* request,
                                       ::google::protobuf::Empty* response
                                       __attribute__((unused))) {
  multiplexing::publisher pblshr;
  auto e{std::make_shared<bbdo::pb_remove_graphs>(*request)};
  pblshr.write(e);
  return grpc::Status::OK;
}

grpc::Status broker_impl::GetProcessingStats(
    grpc::ServerContext* context __attribute__((unused)),
    const ::google::protobuf::Empty* request __attribute__((unused)),
    ::ProcessingStats* response) {
  stats::center::instance().get_processing_stats(response);
  return grpc::Status::OK;
}