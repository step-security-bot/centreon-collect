#include "connection.hh"

connection::connection(const io_context_ptr& io_context,
                       const boost::json::object& conf,
                       const logger_ptr& logger)
    : _io_context(io_context),
      _logger(logger),
      _port(0),
      _conf(conf),
      _state(e_state::not_connected) {
  const boost::json::value* val = conf.if_contains("name");
  if (val) {
    _name = val->as_string().c_str();
  }

  val = conf.if_contains("host");
  if (!val) {
    throw std::invalid_argument("config: host not found for " + _name);
  }
  _host = val->as_string().c_str();

  val = conf.if_contains("port");
  if (val) {
    try {
      _port = val->as_int64();
    } catch (const std::exception& e) {
      SPDLOG_LOGGER_ERROR(_logger, "fail to parse port: {}", e.what());
      throw;
    }
  }

  val = conf.if_contains("user");
  if (!val) {
    throw std::invalid_argument("config: user not found for " + _name);
  }
  _user = val->as_string().c_str();

  val = conf.if_contains("password");
  if (!val) {
    throw std::invalid_argument("config: password not found for " + _name);
  }
  _password = val->as_string().c_str();

  SPDLOG_LOGGER_INFO(_logger, "create connection {}", *this);
}

connection::~connection() {
  SPDLOG_LOGGER_INFO(_logger, "delete connection {}", *this);
}

void connection::dump(std::ostream& s) const {
  s << "this:" << this << " name:" << _name << " host:" << _host
    << " port:" << _port << " user:" << _user;
}

std::ostream& operator<<(std::ostream& s, const connection& to_dump) {
  (&to_dump)->dump(s);
  return s;
}
