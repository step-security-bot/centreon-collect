#include "libpq-fe.h"

#include "pg_connection.hh"

using namespace pg;

pg_connection::pg_connection(const io_context_ptr& io_context,
                             const boost::json::object& conf,
                             const logger_ptr& logger)
    : connection(io_context, conf, logger),
      _socket(*io_context),
      _conn(nullptr) {
  SPDLOG_LOGGER_INFO(_logger, "new pg_connection {}", *this);
}

pg_connection::pointer pg_connection::create(const io_context_ptr& io_context,
                                             const boost::json::object& conf,
                                             const logger_ptr& logger) {
  return pg_connection::pointer(new pg_connection(io_context, conf, logger));
}

pg_connection::~pg_connection() {
  SPDLOG_LOGGER_INFO(_logger, "delete pg_connection {}", *this);
  if (_conn) {
    PQfinish(_conn);
    _conn = nullptr;
  }
}

static const std::unordered_set<std::string> _authorized_keys = {
    "port", "dbname", "user", "password"};

void pg_connection::connect(const time_point& until,
                            const connection_handler& handler) {
  std::vector<const char*> keys, values;
  // has to look-up name?
  std::error_code err;
  asio::ip::make_address(_host, err);
  if (err) {  // name to look up
    keys.push_back("host");
    values.push_back(_host.c_str());
  } else {
    keys.push_back("hostaddr");
    values.push_back(_host.c_str());
  }
  // time out
  std::string time_out;
  time_point now = system_clock::now();
  if (now < until) {
    time_out = std::to_string(
        std::chrono::duration_cast<std::chrono::seconds>(until - now).count());
    keys.push_back("connect_timeout");
    values.push_back(time_out.c_str());
  }

  std::list<std::string> key_value_data;
  // pass other args to postgres
  for (const boost::json::key_value_pair args : _conf) {
    if (_authorized_keys.find(args.key()) != _authorized_keys.end()) {
      const boost::json::string* val = args.value().if_string();
      if (val) {
        key_value_data.emplace_back(args.key().data());
        keys.push_back(key_value_data.rbegin()->c_str());
        key_value_data.emplace_back(val->c_str());
        values.push_back(key_value_data.rbegin()->c_str());
      } else {
        const int64_t* ival = args.value().if_int64();
        if (ival) {
          key_value_data.emplace_back(args.key().data());
          keys.push_back(key_value_data.rbegin()->c_str());
          key_value_data.emplace_back(std::to_string(*ival));
          values.push_back(key_value_data.rbegin()->c_str());
        } else {
          SPDLOG_LOGGER_ERROR(_logger, "{} is not a string", args.key());
        }
      }
    }
  }

  keys.push_back(nullptr);
  values.push_back(nullptr);

  _conn = PQconnectStartParams(keys.data(), values.data(), 0);

  if (!_conn) {
    SPDLOG_LOGGER_ERROR(
        _logger, "PQconnectStartParams fails to create conn obj for {}", *this);
    handler(std::make_error_code(std::errc::not_enough_memory),
            "PQconnectStartParams fail");
    return;
  }

  ConnStatusType status = PQstatus(_conn);
  if (status == CONNECTION_BAD) {
    SPDLOG_LOGGER_ERROR(
        _logger, "PQconnectStartParams fails to parse args for {}: {}, err:{}",
        *this, _conf, PQerrorMessage(_conn));
    handler(std::make_error_code(std::errc::invalid_argument),
            "PQconnectStartParams fail to parse args " +
                std::string(PQerrorMessage(_conn)));
    return;
  }
  connect_poll(handler);
}

void pg_connection::connect_poll(const connection_handler& handler) {
  PostgresPollingStatusType poll_status = PQconnectPoll(_conn);
  if (_socket.native_handle() != PQsocket(_conn)) {
    _socket.assign(asio::ip::tcp::v4(), PQsocket(_conn));
  }
  switch (poll_status) {
    case PGRES_POLLING_WRITING:
      _socket.async_wait(
          socket_type::wait_write,
          [me = shared_from_this(), handler](const std::error_code& err) {
            me->connect_handler(err, handler);
          });
      break;
    case PGRES_POLLING_READING:
      _socket.async_wait(
          socket_type::wait_read,
          [me = shared_from_this(), handler](const std::error_code& err) {
            me->connect_handler(err, handler);
          });
      break;
    case PGRES_POLLING_OK:
      SPDLOG_LOGGER_INFO(_logger, "connected {}", *this);
      handler({}, {});
      break;
    default:
      SPDLOG_LOGGER_ERROR(_logger, "protocol error for {}: {}", *this,
                          PQerrorMessage(_conn));
      handler(std::make_error_code(std::errc::network_unreachable),
              "PQconnectPoll fail" + std::string(PQerrorMessage(_conn)));
      break;
  }
}

void pg_connection::connect_handler(const std::error_code& err,
                                    const connection_handler& handler) {
  if (err) {
    SPDLOG_LOGGER_ERROR(_logger, "network error for {}: {}", *this,
                        err.message());
    handler(err, "fail to connect");
  } else {
    connect_poll(handler);
  }
}

request::pointer pg_connection::create_no_result_request(
    const std::string& req,
    const std::string& end_req) {
  return request::pointer();
}

void pg_connection::start_request(const request::pointer&) {}
