/*
 * Copyright 2022 Centreon (https://www.centreon.com/)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * For more information : contact@centreon.com
 *
 */

#ifndef CCE_TAG_HH
#define CCE_TAG_HH

#include <absl/container/flat_hash_map.h>
#include <memory>
#include <ostream>
#include "com/centreon/engine/namespace.hh"

/* Forward declaration. */
namespace com::centreon::engine {
class tag;
}

using tag_map =
    absl::flat_hash_map<uint32_t, std::shared_ptr<com::centreon::engine::tag>>;
using tag_map_unsafe =
    absl::flat_hash_map<std::string, com::centreon::engine::tag*>;

CCE_BEGIN()

/**
 *  @class tag tag.hh "com/centreon/engine/tag.hh
 *  @brief Object representing a tag
 *
 */
class tag {
 public:
  enum tagtype {
    hostcategory = 1,
    servicecategory = 2,
    hostgroup = 3,
    servicegroup = 4,
  };

 private:
  uint64_t _id;
  tagtype _type;
  std::string _name;

 public:
  static tag_map tags;

  tag(uint64_t id, tagtype typ, const std::string& name);
  ~tag() noexcept = default;
  tag(const tag&) = delete;
  tag& operator=(const tag&) = delete;
  bool operator==(const tag&) = delete;
  bool operator!=(const tag&) = delete;

  uint64_t id() const;
  const std::string& name() const;
  void set_name(const std::string& name);
  tagtype type() const;
  void set_type(const tagtype typ);
  void set_icon_id(uint64_t icon_id);
};

CCE_END()

std::ostream& operator<<(std::ostream& os,
                         com::centreon::engine::tag const& obj);
std::ostream& operator<<(std::ostream& os, tag_map_unsafe const& obj);

#endif  // !CCE_TAG_HH
