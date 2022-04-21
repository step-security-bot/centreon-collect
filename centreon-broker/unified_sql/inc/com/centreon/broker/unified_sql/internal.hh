/*
** Copyright 2013 Centreon
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

#ifndef CCB_UNIFIED_SQL_INTERNAL_HH
#define CCB_UNIFIED_SQL_INTERNAL_HH

#include "bbdo/events.hh"
#include "bbdo/host.pb.h"
#include "bbdo/rebuild_message.pb.h"
#include "bbdo/remove_graph_message.pb.h"
#include "bbdo/service.pb.h"
#include "centreon-broker/core/src/broker.pb.h"
#include "com/centreon/broker/io/protobuf.hh"

CCB_BEGIN()

namespace bbdo {
/**
 * Here is a declaration of pb_rebuild_metrics which is a bbdo event we use to
 * ask rebuild of metrics. MetricIds is a vector of metric ids to rebuild. */
using pb_rebuild_rrd_graphs =
    io::protobuf<IndexIds, make_type(io::bbdo, bbdo::de_rebuild_rrd_graphs)>;
using pb_remove_graphs =
    io::protobuf<ToRemove, make_type(io::bbdo, bbdo::de_remove_graphs)>;
}  // namespace bbdo

namespace neb {
using pb_service =
    io::protobuf<Service, make_type(io::neb, neb::de_pb_service)>;

using pb_host = io::protobuf<Host, make_type(io::neb, neb::de_pb_host)>;
}  // namespace neb

namespace storage {
/**
 * Here is the declaration of the message sent by unified_sql to rrd to rebuild
 * metrics. */
using pb_rebuild_message =
    io::protobuf<RebuildMessage,
                 make_type(io::storage, storage::de_rebuild_message)>;
using pb_remove_graph_message =
    io::protobuf<RemoveGraphMessage,
                 make_type(io::storage, storage::de_remove_graph_message)>;
}  // namespace storage
CCB_END()

#endif  // !CCB_UNIFIED_SQL_INTERNAL_HH