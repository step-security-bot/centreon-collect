/*
** Copyright 2011-2013 Merethis
**
** This file is part of Centreon Engine.
**
** Centreon Engine is free software: you can redistribute it and/or
** modify it under the terms of the GNU General Public License version 2
** as published by the Free Software Foundation.
**
** Centreon Engine is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Centreon Engine. If not, see
** <http://www.gnu.org/licenses/>.
*/

#ifndef CCE_RETENTION_OBJECT_HH
#  define CCE_RETENTION_OBJECT_HH

#  include <string>
#  include "com/centreon/engine/namespace.hh"
#  include "com/centreon/shared_ptr.hh"

CCE_BEGIN()

namespace              retention {
  class                object {
  public:
    enum               type_id {
      comment = 0,
      contact = 1,
      downtime = 2,
      host = 3,
      info = 4,
      program = 5,
      service = 6
    };

                       object(type_id type);
                       object(object const& right);
    virtual            ~object() throw ();
    object&            operator=(object const& right);
    bool               operator==(object const& right) const throw ();
    bool               operator!=(object const& right) const throw ();
    static shared_ptr<object>
                       create(std::string const& type_name);
    virtual void       scheduling_info_is_ok(bool value);
    virtual bool       set(
                         std::string const& key,
                         std::string const& value) = 0;
    type_id            type() const throw ();
    std::string const& type_name() const throw ();

  private:
    type_id            _type;
  };

  typedef shared_ptr<object> object_ptr;
}

CCE_END()

#endif // !CCE_RETENTION_OBJECT_HH
