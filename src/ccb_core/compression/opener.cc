/*
** Copyright 2011-2012 Centreon
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

#include "com/centreon/broker/compression/opener.hh"
#include <memory>
#include "com/centreon/broker/compression/stream.hh"

using namespace com::centreon::broker;
using namespace com::centreon::broker::compression;

/**************************************
 *                                     *
 *           Public Methods            *
 *                                     *
 **************************************/

/**
 *  Default constructor.
 */
//opener::opener() : io::endpoint(false), _level(-1), _size(0) {}

/**
 *  Constructor with parameters.
 */
opener::opener(int level, uint32_t size) 
              : io::endpoint(false),
              level(level),
              size(size) {}

opener::~opener() noexcept {}

/**
 *  Open a compression stream.
 *
 *  @return New compression object.
 */
std::shared_ptr<io::stream> opener::open() {
  std::shared_ptr<io::stream> retval;
  if (_from)
    retval = _open(_from->open());
  return retval;
}

/**************************************
 *                                     *
 *          Private Methods            *
 *                                     *
 **************************************/

/**
 *  Open a compression stream.
 *
 *  @return New compression object.
 */
std::shared_ptr<io::stream> opener::_open(std::shared_ptr<io::stream> base) {
  std::shared_ptr<io::stream> retval;
  if (base) {
    retval.reset(new stream(level, size));
    retval->set_substream(base);
  }
  return retval;
}
