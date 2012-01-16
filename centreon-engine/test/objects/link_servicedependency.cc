/*
** Copyright 2011 Merethis
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

#include <QDebug>
#include <exception>
#include "error.hh"
#include "utils.hh"
#include "macros.hh"
#include "objects/servicedependency.hh"
#include "objects/timeperiod.hh"
#include "create_object.hh"

using namespace com::centreon::engine::objects;
using namespace test::objects;

static bool create_and_link(bool has_dependency_period) {
  init_object_skiplists();
  servicedependency* obj = create_servicedependency(1);
  timeperiod* dependency_period = NULL;
  bool ret = true;

  if (has_dependency_period == true)
    dependency_period = create_timeperiod(1);

  try {
    link(obj, dependency_period);
    if (!obj->master_service_ptr
        || !obj->dependent_service_ptr
        || obj->dependency_period_ptr != dependency_period)
      ret = false;
  }
  catch (std::exception const& e) {
    (void)e;
    ret = false;
  }

  release(obj);
  release(dependency_period);
  free_object_skiplists();
  return (ret);
}

static void link_null_pointer() {
  try {
    link(static_cast<servicedependency*>(NULL), NULL);
  }
  catch (std::exception const& e) {
    (void)e;
  }
}

static void link_null_name() {
  init_object_skiplists();
  servicedependency* obj = NULL;
  try {
    obj = create_servicedependency(1);

    delete[] obj->host_name;
    obj->host_name = NULL;

    link(obj, NULL);
  }
  catch (std::exception const& e) {
    (void)e;
  }
  release(obj);
  free_object_skiplists();
}

static void link_null_description() {
  init_object_skiplists();
  servicedependency* obj = NULL;
  try {
    obj = create_servicedependency(1);

    delete[] obj->service_description;
    obj->service_description = NULL;

    link(obj, NULL);
  }
  catch (std::exception const& e) {
    (void)e;
  }
  release(obj);
  free_object_skiplists();
}


static void link_null_dependent_name() {
  init_object_skiplists();
  servicedependency* obj = NULL;

  try {
    obj = create_servicedependency(1);

    delete[] obj->dependent_host_name;
    obj->dependent_host_name = NULL;

    link(obj, NULL);
  }
  catch (std::exception const& e) {
    (void)e;
  }
  release(obj);
  free_object_skiplists();
}

static void link_null_dependent_description() {
  init_object_skiplists();
  servicedependency* obj = NULL;

  try {
    obj = create_servicedependency(1);

    delete[] obj->dependent_service_description;
    obj->dependent_service_description = NULL;

    link(obj, NULL);
  }
  catch (std::exception const& e) {
    (void)e;
  }
  release(obj);
  free_object_skiplists();
}

static void link_without_dependency_period() {
  if (create_and_link(false) == true)
    throw (engine_error() << Q_FUNC_INFO << " invalid return.");
}

static void link_with_valid_objects() {
  if (create_and_link(true) == true)
    throw (engine_error() << Q_FUNC_INFO << " invalid return.");
}

int main() {
  try {
    link_null_pointer();
    link_null_name();
    link_null_description();
    link_null_dependent_name();
    link_null_dependent_description();
    link_without_dependency_period();
    link_with_valid_objects();
  }
  catch (std::exception const& e) {
    qDebug() << "error: " << e.what();
    free_memory(get_global_macros());
    return (1);
  }
  return (0);
}
