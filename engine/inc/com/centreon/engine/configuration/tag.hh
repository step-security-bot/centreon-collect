/*
** Copyright 2022 Centreon
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
** For more information : contact@centreon.com
*/

#ifndef CCE_CONFIGURATION_TAG_HH
#define CCE_CONFIGURATION_TAG_HH

#include <absl/container/flat_hash_map.h>
#include <string>
#include "com/centreon/engine/configuration/object.hh"
#include "com/centreon/engine/namespace.hh"

CCE_BEGIN()

namespace configuration {
class tag : public object {
 public:
  using key_type = uint64_t;

  enum tagtype {
    none = 0,
    hostcategory = 1,
    servicecategory = 2,
    hostgroup = 3,
    servicegroup = 4,
  };

 private:
  typedef bool (*setter_func)(tag&, const char*);
  key_type _id;
  tagtype _type;
  std::string _name;

  bool _set_id(uint64_t id);
  bool _set_type(const std::string& type);
  bool _set_name(const std::string& name);

 public:
  tag(const key_type& id = 0);
  tag(const tag& other);
  ~tag() noexcept override = default;
  tag& operator=(const tag& other);
  bool operator==(const tag& other) const noexcept;
  bool operator!=(const tag& other) const noexcept;
  bool operator<(const tag& other) const noexcept;
  void check_validity() const override;
  const key_type& key() const noexcept;
  void merge(const object& obj) override;
  bool parse(const char* key, const char* value) override;

  uint32_t type() const noexcept;
  const std::string& name() const noexcept;

  static const absl::flat_hash_map<std::string, setter_func> _setters;
};

typedef std::set<tag> set_tag;
}  // namespace configuration

CCE_END()

#endif  // !CCE_CONFIGURATION_TAG_HH