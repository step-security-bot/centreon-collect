/*
** Copyright 2015 Merethis
**
** This file is part of Centreon Broker.
**
** Centreon Broker is free software: you can redistribute it and/or
** modify it under the terms of the GNU General Public License version 2
** as published by the Free Software Foundation.
**
** Centreon Broker is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Centreon Broker. If not, see
** <http://www.gnu.org/licenses/>.
*/

#ifndef CCB_GRAPHITE_MACRO_CACHE_HH
#  define CCB_GRAPHITE_MACRO_CACHE_HH

#  include <map>
#  include <string>
#  include <QHash>
#  include "com/centreon/broker/instance_broadcast.hh"
#  include "com/centreon/broker/io/factory.hh"
#  include "com/centreon/broker/namespace.hh"
#  include "com/centreon/broker/misc/shared_ptr.hh"
#  include "com/centreon/broker/persistent_cache.hh"
#  include "com/centreon/broker/neb/instance.hh"
#  include "com/centreon/broker/neb/host.hh"
#  include "com/centreon/broker/neb/service.hh"
#  include "com/centreon/broker/storage/index_mapping.hh"
#  include "com/centreon/broker/storage/metric_mapping.hh"

CCB_BEGIN()

namespace         graphite {
  /**
   *  @class macro_cache macro_cache.hh "com/centreon/broker/graphite/macro_cache.hh"
   *  @brief Data cache for graphite macro.
   */
  class            macro_cache {
  public:
                   macro_cache(misc::shared_ptr<persistent_cache> const& cache);
                   ~macro_cache();

    void           write(misc::shared_ptr<io::data> const& data);

    storage::index_mapping const&
                   get_index_mapping(unsigned int index_id) const;
    storage::metric_mapping const&
                   get_metric_mapping(unsigned int metric_id) const;
    QString const& get_host_name(unsigned int host_id) const;
    QString const& get_service_description(
                     unsigned int host_id,
                     unsigned int service_id) const;
    QString const& get_instance(unsigned int instance_id) const;

  private:
                   macro_cache(macro_cache const& f);
    macro_cache&   operator=(macro_cache const& f);

    void           _process_instance(instance_broadcast const& in);
    void           _process_host(neb::host const& h);
    void           _process_service(neb::service const& s);
    void           _process_index_mapping(storage::index_mapping const& im);
    void           _process_metric_mapping(storage::metric_mapping const& mm);
    void           _save_to_disk();

    misc::shared_ptr<persistent_cache>
                   _cache;
    QHash<unsigned int, instance_broadcast>
                   _instances;
    QHash<unsigned int, neb::host>
                   _hosts;
    QHash<QPair<unsigned int, unsigned int>, neb::service>
                   _services;
    QHash<unsigned int, storage::index_mapping>
                   _index_mappings;
    QHash<unsigned int, storage::metric_mapping>
                   _metric_mappings;
  };
}

CCB_END()

#endif // !CCB_GRAPHITE_MACRO_CACHE_HH