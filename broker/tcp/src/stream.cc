/**
 * Copyright 2011 - 2022 Centreon (https://www.centreon.com/)
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

#include "com/centreon/broker/tcp/stream.hh"

#include <sys/socket.h>
#include <sys/time.h>

#include <system_error>

#include "com/centreon/broker/io/raw.hh"
#include "com/centreon/broker/log_v2.hh"
#include "com/centreon/broker/pool.hh"
#include "com/centreon/broker/tcp/acceptor.hh"
#include "com/centreon/broker/tcp/tcp_async.hh"
#include "com/centreon/exceptions/msg_fmt.hh"

using namespace com::centreon::broker;
using namespace com::centreon::broker::tcp;
using namespace com::centreon::exceptions;

std::atomic<size_t> stream::_total_tcp_count{0};

/**
 * @brief Stream constructor used by a connector. The stream establishes a
 * connection to the host server listening on the given port.
 * read_timeout is a duration in seconds used to read on the socket.
 *
 * @param host The host to connect to.
 * @param port The port used by the host to listen.
 * @param read_timeout The read_timeout in seconds or -1 if no timeout.
 */
stream::stream(const tcp_config::pointer& conf)
    : io::stream("TCP"),
      _conf(conf),
      _connection(tcp_async::instance().create_connection(_conf)),
      _parent(nullptr) {
  assert(_connection->port());
  _total_tcp_count++;
  log_v2::tcp()->trace("New stream to {}:{}", _conf->get_host(),
                       _conf->get_port());
  log_v2::tcp()->info(
      "{} TCP streams are configured on a thread pool of {} threads",
      _total_tcp_count, pool::instance().get_pool_size());
}

/**
 * @brief Stream constructor for a server. The connection is already running.
 * We just specify the read_timeout which is a duration in seconds.
 *
 * @param conn The connection to use by this stream.
 * @param read_timeout A duration in seconds or -1 if no timeout.
 */
stream::stream(const tcp_connection::pointer& conn,
               const tcp_config::pointer& conf)
    : io::stream("TCP"), _conf(conf), _connection(conn), _parent(nullptr) {
  assert(_connection->port());
  _total_tcp_count++;
  log_v2::tcp()->info("New stream to {}:{}", _conf->get_host(),
                      _conf->get_port());
  log_v2::tcp()->info(
      "{} TCP streams are configured on a thread pool of {} threads",
      _total_tcp_count, pool::instance().get_pool_size());
}

/**
 *  Destructor.
 */
stream::~stream() noexcept {
  _total_tcp_count--;
  log_v2::tcp()->info(
      "TCP stream destroyed. Still {} configured on a thread pool of {} "
      "threads",
      _total_tcp_count, pool::instance().get_pool_size());
  log_v2::tcp()->trace("stream closed");
  if (_connection->socket().is_open())
    _connection->close();

  if (_parent)
    _parent->remove_child(peer());
}

/**
 *  Get peer name.
 *
 *  @return Peer name.
 */
std::string stream::peer() const {
  return fmt::format("tcp://{}", _connection->peer());
}

/**
 *  Read data with timeout.
 *
 *  @param[out] d         Received event if any.
 *  @param[in]  deadline  Timeout in seconds.
 *
 *  @return Respects io::stream::read()'s return value.
 */
bool stream::read(std::shared_ptr<io::data>& d, time_t deadline) {
  log_v2::tcp()->trace("read on stream");

  // Set deadline.
  {
    time_t now = ::time(nullptr);
    if (_conf->get_read_timeout() != -1 &&
        (deadline == static_cast<time_t>(-1) ||
         now + _conf->get_read_timeout() < deadline))
      deadline = now + _conf->get_read_timeout() / 1000;
  }

  if (_connection->is_closed()) {
    d.reset(new io::raw);
    throw msg_fmt("Connection lost");
  }

  bool timeout = false;
  d.reset(new io::raw(_connection->read(deadline, &timeout)));
  std::shared_ptr<io::raw> data{std::static_pointer_cast<io::raw>(d)};
  log_v2::tcp()->trace("TCP Read done : {} bytes", data->get_buffer().size());
  return !timeout;
}

/**
 *  Set parent socket.
 *
 *  @param[in,out] parent  Parent socket.
 */
void stream::set_parent(acceptor* parent) {
  _parent = parent;
}

int32_t stream::flush() {
  return _connection->flush();
}

int32_t stream::stop() {
  int32_t retval = 0;
  try {
    retval = flush();
  } catch (const std::exception& e) {
    log_v2::tcp()->error("tcp: error during stop: {}", e.what());
  }
  return retval;
}

/**
 *  Write data to the socket.
 *
 *  @param[in] d Data to write.
 *
 *  @return Number of events acknowledged.
 */
int32_t stream::write(std::shared_ptr<io::data> const& d) {
  log_v2::tcp()->trace("write event of type {} on tcp stream", d->type());
  // Check that data exists and should be processed.
  assert(d);

  if (_connection->is_closed())
    throw msg_fmt("Connection lost");

  if (d->type() == io::raw::static_type()) {
    std::shared_ptr<io::raw> r(std::static_pointer_cast<io::raw>(d));
    log_v2::tcp()->trace("TCP: write request of {} bytes to peer '{}:{}'",
                         r->size(), _conf->get_host(), _conf->get_port());
    log_v2::tcp()->trace("write {} bytes", r->size());
    try {
      return _connection->write(r->get_buffer());
    } catch (std::exception const& e) {
      log_v2::tcp()->error("Socket gone");
      throw;
    }
  }
  return 1;
}

/**
 * @brief wait for connection write queue empty
 *
 * @param ms_timeout
 * @return true queue is empty
 * @return false timeout expired
 */
bool stream::wait_for_all_events_written(unsigned ms_timeout) {
  if (_connection->is_closed()) {
    return true;
  }

  return _connection->wait_for_all_events_written(ms_timeout);
}
