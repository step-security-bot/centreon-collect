/**
* Copyright 2011-2014 Merethis
*
* This file is part of Centreon Engine.
*
* Centreon Engine is free software: you can redistribute it and/or
* modify it under the terms of the GNU General Public License version 2
* as published by the Free Software Foundation.
*
* Centreon Engine is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Centreon Engine. If not, see
* <http://www.gnu.org/licenses/>.
*/

#include "com/centreon/engine/configuration/object.hh"
#include "com/centreon/engine/configuration/anomalydetection.hh"
#include "com/centreon/engine/configuration/command.hh"
#include "com/centreon/engine/configuration/connector.hh"
#include "com/centreon/engine/configuration/contact.hh"
#include "com/centreon/engine/configuration/contactgroup.hh"
#include "com/centreon/engine/configuration/host.hh"
#include "com/centreon/engine/configuration/hostdependency.hh"
#include "com/centreon/engine/configuration/hostescalation.hh"
#include "com/centreon/engine/configuration/hostextinfo.hh"
#include "com/centreon/engine/configuration/hostgroup.hh"
#include "com/centreon/engine/configuration/service.hh"
#include "com/centreon/engine/configuration/servicedependency.hh"
#include "com/centreon/engine/configuration/serviceescalation.hh"
#include "com/centreon/engine/configuration/serviceextinfo.hh"
#include "com/centreon/engine/configuration/servicegroup.hh"
#include "com/centreon/engine/configuration/severity.hh"
#include "com/centreon/engine/configuration/tag.hh"
#include "com/centreon/engine/configuration/timeperiod.hh"
#include "com/centreon/engine/exceptions/error.hh"
#include "com/centreon/engine/string.hh"

using namespace com::centreon;
using namespace com::centreon::engine::configuration;

#define SETTER(type, method) \
  &object::setter<object, type, &object::method>::generic

object::setters const object::_setters[] = {
    {"use", SETTER(std::string const&, _set_templates)},
    {"name", SETTER(std::string const&, _set_name)},
    {"register", SETTER(bool, _set_should_register)}};

/**
 *  Constructor.
 *
 *  @param[in] type      The object type.
 */
object::object(object::object_type type)
    : _is_resolve(false), _should_register(true), _type(type) {}

/**
 *  Copy constructor.
 *
 *  @param[in] right The object to copy.
 */
object::object(object const& right) {
  operator=(right);
}

/**
 *  Destructor.
 */
object::~object() noexcept {}

/**
 *  Copy constructor.
 *
 *  @param[in] right The object to copy.
 *
 *  @return This object.
 */
object& object::operator=(object const& right) {
  if (this != &right) {
    _is_resolve = right._is_resolve;
    _name = right._name;
    _should_register = right._should_register;
    _templates = right._templates;
    _type = right._type;
  }
  return *this;
}

/**
 *  Equal operator.
 *
 *  @param[in] right The object to compare.
 *
 *  @return True if is the same object, otherwise false.
 */
bool object::operator==(object const& right) const noexcept {
  return (_name == right._name && _type == right._type &&
          _is_resolve == right._is_resolve &&
          _should_register == right._should_register &&
          _templates == right._templates);
}

/**
 *  Equal operator.
 *
 *  @param[in] right The object to compare.
 *
 *  @return True if is not the same object, otherwise false.
 */
bool object::operator!=(object const& right) const noexcept {
  return !operator==(right);
}

/**
 *  Create object with object type.
 *
 *  @param[in] type_name The object type name.
 *
 *  @return New object.
 */
object_ptr object::create(std::string const& type_name) {
  object_ptr obj;
  if (type_name == "service")
    obj = std::make_shared<configuration::service>();
  else if (type_name == "host")
    obj = std::make_shared<configuration::host>();
  else if (type_name == "contact")
    obj = std::make_shared<configuration::contact>();
  else if (type_name == "contactgroup")
    obj = std::make_shared<configuration::contactgroup>();
  else if (type_name == "servicegroup")
    obj = std::make_shared<configuration::servicegroup>();
  else if (type_name == "hostgroup")
    obj = std::make_shared<configuration::hostgroup>();
  else if (type_name == "servicedependency")
    obj = std::make_shared<configuration::servicedependency>();
  else if (type_name == "serviceescalation")
    obj = std::make_shared<configuration::serviceescalation>();
  else if (type_name == "hostdependency")
    obj = std::make_shared<configuration::hostdependency>();
  else if (type_name == "hostescalation")
    obj = std::make_shared<configuration::hostescalation>();
  else if (type_name == "command")
    obj = std::make_shared<configuration::command>();
  else if (type_name == "timeperiod")
    obj = std::make_shared<configuration::timeperiod>();
  else if (type_name == "connector")
    obj = std::make_shared<configuration::connector>();
  else if (type_name == "serviceextinfo")
    obj = std::make_shared<configuration::serviceextinfo>();
  else if (type_name == "hostextinfo")
    obj = std::make_shared<configuration::hostextinfo>();
  else if (type_name == "anomalydetection")
    obj = std::make_shared<configuration::anomalydetection>();
  else if (type_name == "severity")
    obj = std::make_shared<configuration::severity>();
  else if (type_name == "tag")
    obj = std::make_shared<configuration::tag>();
  return obj;
}

/**
 *  Get the object name.
 *
 *  @return The object name.
 */
std::string const& object::name() const noexcept {
  return _name;
}

/**
 *  Parse and set the object property.
 *
 *  @param[in] key   The property name.
 *  @param[in] value The property value.
 *
 *  @return True on success, otherwise false.
 */
bool object::parse(char const* key, char const* value) {
  for (unsigned int i(0); i < sizeof(_setters) / sizeof(_setters[0]); ++i)
    if (!strcmp(_setters[i].name, key))
      return (_setters[i].func)(*this, value);
  return false;
}

/**
 *  Parse and set the object property.
 *
 *  @param[in] line The configuration line.
 *
 *  @return True on success, otherwise false.
 */
bool object::parse(std::string const& line) {
  std::size_t pos(line.find_first_of(" \t\r", 0));
  std::string key;
  std::string value;
  if (pos == std::string::npos)
    key = line;
  else {
    key.assign(line, 0, pos);
    value.assign(line, pos + 1, std::string::npos);
  }
  string::trim(value);
  if (!parse(key.c_str(), value.c_str()))
    return object::parse(key.c_str(), value.c_str());
  return true;
}

/**
 *  Resolve template object.
 *
 *  @param[in, out] templates The template list.
 */
void object::resolve_template(map_object& templates) {
  if (_is_resolve)
    return;

  _is_resolve = true;
  for (std::string& s : _templates) {
    map_object::iterator tmpl = templates.find(s);
    if (tmpl == templates.end())
      throw engine_error() << "Cannot merge object of type '" << s << "'";
    tmpl->second->resolve_template(templates);
    merge(*tmpl->second);
  }
}

/**
 *  Check if object should be registered.
 *
 *  @return True if object should be registered, false otherwise.
 */
bool object::should_register() const noexcept {
  return _should_register;
}

/**
 *  Get the object type.
 *
 *  @return The object type.
 */
object::object_type object::type() const noexcept {
  return _type;
}

/**
 *  Get the object type name.
 *
 *  @return The object type name.
 */
std::string const& object::type_name() const noexcept {
  static std::string const tab[] = {"command",
                                    "connector",
                                    "contact",
                                    "contactgroup",
                                    "host",
                                    "hostdependency",
                                    "hostescalation",
                                    "hostextinfo",
                                    "hostgroup",
                                    "service",
                                    "servicedependency",
                                    "serviceescalation",
                                    "serviceextinfo",
                                    "servicegroup",
                                    "timeperiod",
                                    "anomalydetection"};
  return tab[_type];
}

/**
 *  Set name value.
 *
 *  @param[in] value The new name value.
 *
 *  @return True on success, otherwise false.
 */
bool object::_set_name(std::string const& value) {
  _name = value;
  return true;
}

/**
 *  Set whether or not this object should be registered.
 *
 *  @param[in] value Registration flag.
 *
 *  @return True.
 */
bool object::_set_should_register(bool value) {
  _should_register = value;
  return true;
}

/**
 *  Set templates value.
 *
 *  @param[in] value The new templates value.
 *
 *  @return True on success, otherwise false.
 */
bool object::_set_templates(std::string const& value) {
  _templates.clear();
  string::split(value, _templates, ',');
  return true;
}
