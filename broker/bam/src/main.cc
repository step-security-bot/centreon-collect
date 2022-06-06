/*
** Copyright 2011-2015, 2020-2021 Centreon
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
#include "bbdo/bam/ba_duration_event.hh"
#include "bbdo/bam/ba_event.hh"
#include "bbdo/bam/ba_status.hh"
#include "bbdo/bam/dimension_ba_bv_relation_event.hh"
#include "bbdo/bam/dimension_ba_event.hh"
#include "bbdo/bam/dimension_ba_timeperiod_relation.hh"
#include "bbdo/bam/dimension_bv_event.hh"
#include "bbdo/bam/dimension_kpi_event.hh"
#include "bbdo/bam/dimension_timeperiod.hh"
#include "bbdo/bam/dimension_timeperiod_exception.hh"
#include "bbdo/bam/dimension_timeperiod_exclusion.hh"
#include "bbdo/bam/dimension_truncate_table_signal.hh"
#include "bbdo/bam/inherited_downtime.hh"
#include "bbdo/bam/kpi_event.hh"
#include "bbdo/bam/kpi_status.hh"
#include "bbdo/bam/rebuild.hh"
#include "bbdo/events.hh"
#include "bbdo/storage/index_mapping.hh"
#include "bbdo/storage/metric.hh"
#include "bbdo/storage/metric_mapping.hh"
#include "bbdo/storage/status.hh"
#include "com/centreon/broker/bam/factory.hh"
#include "com/centreon/broker/io/events.hh"
#include "com/centreon/broker/io/protocols.hh"
#include "com/centreon/broker/log_v2.hh"
#include "com/centreon/exceptions/msg_fmt.hh"

using namespace com::centreon::exceptions;
using namespace com::centreon::broker;

// Load count.
namespace {
uint32_t instances(0);
char const* bam_module("bam");
}  // namespace

template <typename T>
void register_bam_event(io::events& e, bam::data_element de, const char* name) {
  e.register_event(make_type(io::bam, de), name, &T::operations, T::entries);
}

extern "C" {
/**
 *  Module version symbol. Used to check for version mismatch.
 */
const char* broker_module_version = CENTREON_BROKER_VERSION;

/**
 * @brief Return an array with modules needed for this one to work.
 *
 * @return An array of const char*
 */
const char* const* broker_module_parents() {
  constexpr static const char* retval[]{"10-neb.so", nullptr};
  return retval;
}

/**
 *  Module deinitialization routine.
 */
void broker_module_deinit() {
  // Decrement instance number.
  if (!--instances) {
    io::protocols::instance().unreg(bam_module);
    // Deregister bam events.
    io::events::instance().unregister_category(io::bam);
  }
}

/**
 *  Module initialization routine.
 *
 *  @param[in] arg Configuration object.
 */
void broker_module_init(void const* arg) {
  (void)arg;

  // Increment instance number.
  if (!instances++) {
    // BAM module.
    log_v2::bam()->info("BAM: module for Centreon Broker {} ",
                        CENTREON_BROKER_VERSION);

    io::protocols::instance().reg(bam_module, std::make_shared<bam::factory>(),
                                  1, 7);

    io::events& e(io::events::instance());

    // Register events.
    {
      e.register_event(make_type(io::storage, storage::de_metric), "metric",
                       &storage::metric::operations, storage::metric::entries,
                       "rt_metrics");
      e.register_event(make_type(io::storage, storage::de_status), "status",
                       &storage::status::operations, storage::status::entries);
      e.register_event(make_type(io::storage, storage::de_index_mapping),
                       "index_mapping", &storage::index_mapping::operations,
                       storage::index_mapping::entries);
      e.register_event(make_type(io::storage, storage::de_metric_mapping),
                       "metric_mapping", &storage::metric_mapping::operations,
                       storage::metric_mapping::entries);

      register_bam_event<bam::ba_status>(e, bam::de_ba_status, "ba_status");
      register_bam_event<bam::kpi_status>(e, bam::de_kpi_status, "kpi_status");
      register_bam_event<bam::ba_event>(e, bam::de_ba_event, "ba_event");
      register_bam_event<bam::kpi_event>(e, bam::de_kpi_event, "kpi_event");
      register_bam_event<bam::ba_duration_event>(e, bam::de_ba_duration_event,
                                                 "ba_duration_event");
      register_bam_event<bam::dimension_ba_event>(e, bam::de_dimension_ba_event,
                                                  "dimension_ba_event");
      register_bam_event<bam::dimension_kpi_event>(
          e, bam::de_dimension_kpi_event, "dimension_kpi_event");
      register_bam_event<bam::dimension_ba_bv_relation_event>(
          e, bam::de_dimension_ba_bv_relation_event,
          "dimension_ba_bv_relation_event");
      register_bam_event<bam::dimension_bv_event>(e, bam::de_dimension_bv_event,
                                                  "dimension_bv_event");
      register_bam_event<bam::dimension_truncate_table_signal>(
          e, bam::de_dimension_truncate_table_signal,
          "dimension_truncate_table_signal");
      register_bam_event<bam::rebuild>(e, bam::de_rebuild, "rebuild");
      register_bam_event<bam::dimension_timeperiod>(
          e, bam::de_dimension_timeperiod, "dimension_timeperiod");
      register_bam_event<bam::dimension_ba_timeperiod_relation>(
          e, bam::de_dimension_ba_timeperiod_relation,
          "dimension_ba_timeperiod_relation");
      register_bam_event<bam::dimension_timeperiod_exception>(
          e, bam::de_dimension_timeperiod_exception,
          "dimension_ba_timeperiod_exception");
      register_bam_event<bam::dimension_timeperiod_exclusion>(
          e, bam::de_dimension_timeperiod_exclusion,
          "dimension_timeperiod_exclusion");
      register_bam_event<bam::inherited_downtime>(e, bam::de_inherited_downtime,
                                                  "inherited_downtime");
    }
  }
}
}