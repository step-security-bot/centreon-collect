#ifndef __TSDB__BENCH__CONNECTION_HH
#define __TSDB__BENCH__CONNECTION_HH

#include "request.hh"

class connection : public std::enable_shared_from_this<connection> {
 protected:
  io_context_ptr _io_context;
  logger_ptr _logger;
  std::string _name;
  std::string _host;
  u_int16_t _port;
  std::string _user;
  std::string _password;
  boost::json::object _conf;

  enum class e_state : uint8_t { not_connected, connecting, idle, busy, error };

  e_state _state;
  mutable std::mutex _protect;

  using lock = std::lock_guard<std::mutex>;

 public:
  using pointer = std::shared_ptr<connection>;
  using connection_handler =
      std::function<void(const std::error_code&,
                         const std::string& /*detail of error*/)>;

  connection(const connection&) = delete;
  connection& operator=(const connection&) = delete;

  connection(const io_context_ptr& io_context,
             const boost::json::object& conf,
             const logger_ptr& logger);

  virtual ~connection();

  const std::string& get_name() const { return _name; }
  const std::string& get_host() const { return _host; }
  const u_int16_t& get_port() const { return _port; }
  const std::string& get_user() const { return _user; }
  const std::string& get_password() const { return _password; }

  virtual void dump(std::ostream&) const;

  virtual void connect(const time_point& until,
                       const connection_handler& handler) = 0;

  virtual request::pointer create_no_result_request(
      const std::string& req,
      const std::string& end_req) = 0;

  virtual void start_request(const request::pointer&) = 0;
};

std::ostream& operator<<(std::ostream& s, const connection& to_dump);

#endif