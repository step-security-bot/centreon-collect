#ifndef __TSDB__BENCH__REQUEST_HH
#define __TSDB__BENCH__REQUEST_HH

class request : public std::enable_shared_from_this<request> {
 public:
  using pointer = std::shared_ptr<request>;
  using callback = std::function<
      void(const std::error_code&, const std::string&, const pointer&)>;

 protected:
  std::atomic_bool _callback_called;
  callback _callback;

  void call_callback(const std::error_code& err, const std::string& err_detail);

 public:
  template <class callback_type>
  request(callback_type&& callback);
  virtual ~request() = default;

  virtual void dump(std::ostream& s) const;

  virtual void in(int64_t) = 0;
  virtual void in(uint64_t) = 0;
  virtual void in(float) = 0;
  virtual void in(double) = 0;
  virtual void in(const time_point&) = 0;

  template <class const_iterator>
  void in(const_iterator begin, const_iterator end) {
    for (; begin != end; ++begin) {
      *this << *begin;
    }
  }
};

template <class callback_type>
request::request(callback_type&& callback)
    : _callback_called(false), _callback(callback) {}

std::ostream& operator<<(std::ostream& s, const request& req);

inline request& operator<<(request& req, int64_t val) {
  req.in(val);
  return req;
}

inline request& operator<<(request& req, uint64_t val) {
  req.in(val);
  return req;
}

inline request& operator<<(request& req, float val) {
  req.in(val);
  return req;
}

inline request& operator<<(request& req, double val) {
  req.in(val);
  return req;
}

inline request& operator<<(request& req, const time_point& val) {
  req.in(val);
  return req;
}

#endif
