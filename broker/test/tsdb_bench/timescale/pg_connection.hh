#ifndef __TSDB__BENCH__PG_CONNECTION_HH
#define __TSDB__BENCH__PG_CONNECTION_HH

#include "connection.hh"

typedef struct pg_conn PGconn;

namespace pg {
class pg_connection : public ::connection {
  using socket_type = asio::ip::tcp::socket;
  socket_type _socket;
  PGconn* _conn;

  void connect_handler(const std::error_code& err,
                       const connection_handler& handler);

  void connect_poll(const connection_handler& handler);

 protected:
  pg_connection(const io_context_ptr& io_context,
                const boost::json::object& conf,
                const logger_ptr& logger);

 public:
  using pointer = std::shared_ptr<pg_connection>;

  static pointer create(const io_context_ptr& io_context,
                        const boost::json::object& conf,
                        const logger_ptr& logger);
  ~pg_connection();

  pointer shared_from_this() {
    return std::static_pointer_cast<pg_connection>(
        ::connection::shared_from_this());
  }

  void connect(const time_point& until,
               const connection_handler& handler) override;

  request::pointer create_no_result_request(
      const std::string& req,
      const std::string& end_req) override;

  void start_request(const request::pointer&) override;
};
}  // namespace pg

#endif
