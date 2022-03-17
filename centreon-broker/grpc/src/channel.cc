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

#include "grpc_stream.pb.h"

#include "com/centreon/broker/grpc/channel.hh"
#include "com/centreon/broker/misc/string.hh"
#include "com/centreon/broker/misc/trash.hh"
#include "com/centreon/exceptions/msg_fmt.hh"

using namespace com::centreon::broker::grpc;
using namespace com::centreon::exceptions;

static com::centreon::broker::misc::trash<channel> _trash;

namespace com {
namespace centreon {
namespace broker {
namespace stream {
std::ostream& operator<<(std::ostream& st,
                         const centreon_stream::centreon_event& to_dump) {
  if (to_dump.IsInitialized()) {
    if (to_dump.has_buffer()) {
      st << "buff: "
         << com::centreon::broker::misc::string::debug_buf(
                to_dump.buffer().data(), to_dump.buffer().length(), 20);
    }
  }
  return st;
}
}  // namespace stream
namespace grpc {
std::ostream& operator<<(std::ostream& st,
                         const detail_centreon_event& to_dump) {
  if (to_dump.to_dump.IsInitialized()) {
    if (to_dump.to_dump.has_buffer()) {
      st << "buff: "
         << com::centreon::broker::misc::string::debug_buf(
                to_dump.to_dump.buffer().data(),
                to_dump.to_dump.buffer().length(), 100);
    }
  }
  return st;
}
}  // namespace grpc
}  // namespace broker
}  // namespace centreon
}  // namespace com

channel::channel(const std::string& class_name,
                 const grpc_config::pointer& conf)
    : _class_name(class_name),
      _read_pending(false),
      _write_pending(false),
      _error(false),
      _thrown(false),
      _conf(conf) {}

void channel::start() {
  start_read(true);
}

constexpr unsigned second_delay_before_delete = 60u;

void channel::to_trash() {
  _thrown = true;
  log_v2::grpc()->debug("{} this={:p}", __PRETTY_FUNCTION__,
                        static_cast<void*>(this));
  _trash.to_trash(shared_from_this(),
                  time(nullptr) + second_delay_before_delete);
}

int channel::stop() {
  int ret = flush();
  to_trash();
  return ret;
}

/***************************************************************
 *    read section
 ***************************************************************/
std::pair<event_ptr, bool> channel::read(
    const system_clock::time_point& deadline) {
  event_ptr read;
  unique_lock l(_protect);
  if (!_read_queue.empty()) {
    read = _read_queue.front();
    _read_queue.pop_front();
    return std::make_pair(read, true);
  }
  if (is_down()) {
    throw(msg_fmt("{} connexion is down", __PRETTY_FUNCTION__));
  }
  _read_cond.wait_until(l, deadline, [this]() { return !_read_queue.empty(); });
  if (!_read_queue.empty()) {
    read = _read_queue.front();
    _read_queue.pop_front();
    return std::make_pair(read, true);
  }
  return std::make_pair(read, false);
}

void channel::start_read(bool first_read) {
  event_ptr to_read;
  {
    unique_lock l(_protect);
    if (_read_pending) {
      return;
    }
    to_read = _read_current = std::make_shared<grpc_event_type>();

    _read_pending = true;
    if (first_read) {
      log_v2::grpc()->debug("{} start call and read", __PRETTY_FUNCTION__);
    } else {
      log_v2::grpc()->trace("{} start read", __PRETTY_FUNCTION__);
    }
  }
  if (to_read) {
    start_read(to_read, first_read);
  }
}

void channel::on_read_done(bool ok) {
  if (ok) {
    {
      unique_lock l(_protect);
      if (log_v2::grpc()->level() == spdlog::level::trace) {
        log_v2::grpc()->trace("{}::{} receive:{}", _class_name, __FUNCTION__,
                              detail_centreon_event(*_read_current));
      } else {
        log_v2::grpc()->debug("{}::{} receive:{}", _class_name, __FUNCTION__,
                              *_read_current);
      }
      _read_queue.push_back(_read_current);
      _read_cond.notify_one();
      _read_pending = false;
    }
    start_read(false);
  } else {
    log_v2::grpc()->error("{}::{} ", _class_name, __FUNCTION__);
    _error = true;
  }
}

/***************************************************************
 *    write section
 ***************************************************************/
int channel::write(const event_ptr& to_send) {
  if (is_down()) {
    throw(msg_fmt("{} connexion is down", __PRETTY_FUNCTION__));
  }
  {
    unique_lock l(_protect);
    _write_queue.push_back(to_send);
  }
  start_write();
  return 0;
}

void channel::start_write() {
  event_ptr write_current;
  {
    unique_lock l(_protect);
    if (_write_pending) {
      return;
    }
    if (_write_queue.empty()) {
      return;
    }
    _write_pending = true;
    write_current = _write_current = _write_queue.front();
  }
  if (log_v2::grpc()->level() == spdlog::level::trace) {
    log_v2::grpc()->trace("{} write:{}", __PRETTY_FUNCTION__,
                          detail_centreon_event(*write_current));
  } else {
    log_v2::grpc()->debug("{} write:{}", __PRETTY_FUNCTION__, *write_current);
  }
  start_write(write_current);
}

void channel::on_write_done(bool ok) {
  if (ok) {
    bool data_to_write = false;
    {
      unique_lock l(_protect);
      _write_pending = false;
      if (log_v2::grpc()->level() == spdlog::level::trace) {
        log_v2::grpc()->trace("{} write done :{}", __PRETTY_FUNCTION__,
                              detail_centreon_event(*_write_current));
      } else {
        log_v2::grpc()->debug("{} write done :{}", __PRETTY_FUNCTION__,
                              *_write_current);
      }

      _write_queue.pop_front();
      data_to_write = !_write_queue.empty();
    }
    if (data_to_write) {
      start_write();
    }
  } else {
    unique_lock l(_protect);
    log_v2::grpc()->error("{}::{} write failed :{}", _class_name, __FUNCTION__,
                          *_write_current);
    _error = true;
  }
}

int channel::flush() {
  return 0;
}
