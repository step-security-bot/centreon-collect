/*
** Copyright 2022 Centreon
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
** For more information : contact@centreon.com
*/

#ifndef CCB_GRPC_SERVER_HH
#define CCB_GPRC_SERVER_HH

#include "channel.hh"

namespace grpc {
class Server;
}

CCB_BEGIN()

namespace grpc {

class accepted_service
    : public ::grpc::ServerBidiReactor<grpc_event_type, grpc_event_type>,
      public channel {
 public:
  using pointer = std::shared_ptr<accepted_service>;

  pointer shared_from_this() {
    return std::static_pointer_cast<accepted_service>(
        channel::shared_from_this());
  }

  accepted_service(const grpc_config::pointer& conf);
  ~accepted_service();

  void start();
  void start_read(event_ptr&, bool first_read) override;
  void start_write(const event_ptr&) override;

  void desactivate();

  void OnReadDone(bool ok) override;

  void OnWriteDone(bool ok) override;

  void OnDone() override{};

  void OnCancel() override;
};

class server : public centreon_stream::centreon_bbdo::Service,
               public std::enable_shared_from_this<server> {
  std::unique_ptr<::grpc::Server> _server;
  std::queue<accepted_service::pointer> _accepted;
  grpc_config::pointer _conf;
  mutable std::mutex _protect;
  mutable std::condition_variable _accept_cond;

  server(const grpc_config::pointer& conf);

  ::grpc::ServerBidiReactor<grpc_event_type, grpc_event_type>* exchange(
      ::grpc::CallbackServerContext*);

  void start();

 public:
  using pointer = std::shared_ptr<server>;

  static pointer create(const grpc_config::pointer& conf);

  ~server() = default;

  bool is_ready() const;

  std::unique_ptr<io::stream> open();
  std::unique_ptr<io::stream> open(const system_clock::time_point& dead_line);
};

}  // namespace grpc

CCB_END()

#endif  // !CCB_GRPC_STREAM_HH