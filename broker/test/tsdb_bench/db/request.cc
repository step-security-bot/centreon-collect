#include "request.hh"

void request::call_callback(const std::error_code& err,
                            const std::string& err_detail) {
  bool desired = false;
  if (_callback_called.compare_exchange_strong(desired, true)) {
    _callback(err, err_detail, shared_from_this());
  }
}

void request::dump(std::ostream& s) const {
  s << "this:" << this;
}

std::ostream& operator<<(std::ostream& s, const request& req) {
  (&req)->dump(s);
  return s;
}
