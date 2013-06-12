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

#include "com/centreon/engine/error.hh"
#include "com/centreon/engine/globals.hh"
#include "com/centreon/engine/misc/string.hh"
#include "com/centreon/engine/retention/info.hh"
#include "com/centreon/engine/retention/parser.hh"
#include "com/centreon/engine/retention/object.hh"

using namespace com::centreon::engine::retention;

/**
 *  Default constructor.
 */
parser::parser() {

}

/**
 *  Destructor.
 */
parser::~parser() throw () {

}

/**
 *  Parse configuration file.
 *
 *  @param[in] path The configuration file path.
 */
void parser::parse(std::string const& path) {
  std::ifstream stream(path.c_str());
  if (!stream.is_open())
    throw (engine_error() << "retention: parse retention "
           "failed: can't open file '" << path << "'");

  // Big speedup when reading retention.dat in bulk.
  defer_downtime_sorting = 1;
  defer_comment_sorting = 1;

  bool scheduling_info_is_ok(false);
  shared_ptr<object> obj;
  std::string input;
  while (_get_next_line(stream, input)) {
    if (obj.is_null()) {
      std::size_t pos(input.find_first_of(" \t"));
      if (pos == std::string::npos)
        continue;
      obj = object::create(input.substr(0, pos));
      if (!obj.is_null())
        obj->scheduling_info_is_ok(scheduling_info_is_ok);
    }
    else if (input != "}") {
      std::string key;
      std::string value;
      if (_get_data(input, key, value, "="))
        obj->set(key, value);
    }
    else {
      if (obj->type() == object::info) {
        shared_ptr<info> info(obj);
        scheduling_info_is_ok = info->scheduling_info_is_ok();
      }
      obj.clear();
    }
  }

  // Sort all downtimes.
  sort_downtime();
  // Sort all comments.
  sort_comments();
}

/**
 *  Get key and value from line.
 *
 *  @param[in]  line  The line to extract data.
 *  @param[out] key   The key to fill.
 *  @param[out] value The value to fill.
 *  @param[in]  delim The delimiter.
 */
bool parser::_get_data(
       std::string const& line,
       std::string& key,
       std::string& value,
       char const* delim) {
  std::size_t pos(line.find_first_of(delim, 0));
  if (pos == std::string::npos)
    return (false);

  key = line.substr(0, pos);
  misc::trim(key);

  value = line.substr(pos + 1);
  misc::trim(value);
  return (true);
}

/**
 *  Get the next valid line.
 *
 *  @param[in, out] stream The current stream to read new line.
 *  @param[out]     line   The line to fill.
 *
 *  @return True if data is available, false if no data.
 */
bool parser::_get_next_line(std::ifstream& stream, std::string& line) {
  while (std::getline(stream, line, '\n')) {
    misc::trim(line);
    if (!line.empty()) {
      char c(line[0]);
      if (c != '#' && c != ';' && c != '\x0')
        return (true);
    }
  }
  return (false);
}

