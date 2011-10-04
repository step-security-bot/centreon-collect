/*
** Copyright 1999-2009 Ethan Galstad
** Copyright 2009-2010 Nagios Core Development Team and Community Contributors
** Copyright 2011      Merethis
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

#include <QCoreApplication>
#include <errno.h>
#include <exception>
#include <iostream>
#include <limits.h>
#include <QDir>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include "comments.hh"
#include "downtime.hh"
#include "globals.hh"
#include "statusdata.hh"
#include "sretention.hh"
#include "perfdata.hh"
#include "broker.hh"
#include "nebmods.hh"
#include "notifications.hh"
#include "config.hh"
#include "utils.hh"
#include "broker/loader.hh"
#include "logging.hh"
#include "configuration/applier/logging.hh"
#include "logging/logger.hh"
#include "logging/broker.hh"
#include "logging/engine.hh"
#include "engine.hh"
#include "compatibility/common.h"

using namespace com::centreon::engine;
using namespace com::centreon::engine::logging;

// Engine version if not defined by build system.
#ifndef ENGINE_VERSION
# define ENGINE_VERSION "(unknown)"
#endif /* !ENGINE_VERSION */

// Error message when configuration parsing fail.
#define ERROR_CONFIGURATION						\
  "    Check your configuration file(s) to ensure that they contain valid\n" \
  "    directives and data defintions. If you are upgrading from a\n"	\
  "    previous version of Centreon Engine, you should be aware that some\n" \
  "    variables/definitions may have been removed or modified in this\n" \
  "    version. Make sure to read the documentation regarding the config\n" \
  "    files, as well as the version changelog to find out what has\n"	\
  "    changed.\n"

int main(int argc, char** argv) {
  QCoreApplication app(argc, argv);

  configuration::applier::logging apply_log;

  int error = FALSE;
  int display_license = FALSE;
  int display_help = FALSE;
  int c = 0;
  struct tm* tm, tm_s;
  time_t now;
  char datestring[256];
  nagios_macros* mac;

  // Get global macros.
  mac = get_global_macros();

#ifdef HAVE_GETOPT_H
  int option_index = 0;
  static struct option long_options[] = {
    {"dont-verify-paths", no_argument, NULL, 'x'},
    {"help", no_argument, NULL, 'h'},
    {"license", no_argument, NULL, 'V'},
    {"precache-objects", no_argument, NULL, 'p'},
    {"test-scheduling", no_argument, NULL, 's'},
    {"use-precached-objects", no_argument, NULL, 'u'},
    {"verify-config", no_argument, NULL, 'v'},
    {"version", no_argument, NULL, 'V'},
    {NULL, no_argument, NULL, '\0'}
  };
#endif // HAVE_GETOPT_H

  // Make sure we have the correct number of command line arguments.
  if (argc < 2)
    error = TRUE;

  // Process all command line arguments.
#ifdef HAVE_GETOPT_H
  while ((c = getopt_long(argc, argv, "+hVvsxpu", long_options, &option_index)) != -1) {
#else
  while ((c = getopt(argc, argv, "+hVvsxpu")) != -1) {
#endif // HAVE_GETOPT_H

    // Process flag.
    switch (c) {
     case '?': // Usage.
     case 'h':
      display_help = TRUE;
      break ;
     case 'V': // Version.
      display_license = TRUE;
      break ;
     case 'v': // Verify config.
      verify_config = TRUE;
      break ;
     case 's': // Scheduling Check.
      test_scheduling = TRUE;
      break ;
     case 'x': // Don't verify circular paths.
      verify_circular_paths = FALSE;
      break ;
     case 'p': // Precache object config.
      precache_objects = TRUE;
      break ;
     case 'u': // Use precached object config.
      use_precached_objects = TRUE;
      break ;
     default:
      break ;
    }
  }

  // Make sure we have the right combination of arguments.
  if ((TRUE == precache_objects)
      && (FALSE == test_scheduling)
      && (FALSE == verify_config)) {
    error = TRUE;
    display_help = TRUE;
  }

  // Just display the license.
  if (TRUE == display_license) {
    logger(log_info_message, basic)
      << "Centreon Engine is free software: you can redistribute it and/or modify\n"
      << "it under the terms of the GNU General Public License version 2 as\n"
      << "published by the Free Software Foundation.\n"
      << "\n"
      << "Centreon Engine is distributed in the hope that it will be useful, but\n"
      << "WITHOUT ANY WARRANTY; without even the implied warranty of\n"
      << "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU\n"
      << "General Public License for more details.\n"
      << "\n"
      << "You should have received a copy of the GNU General Public License along\n"
      << "with Centreon Engine. If not, see <http://www.gnu.org/licenses/>.\n\n"
      << "Centreon Engine version: " << get_program_version();
    exit(EXIT_SUCCESS);
  }

  // Make sure we got the main config file on the command line.
  if (optind >= argc)
    error = TRUE;

  // If there are no command line options or if an error occured, print usage.
  if ((TRUE == error) || (TRUE == display_help)) {
    logger(log_info_message, basic)
      << "Usage: " << argv[0] << " [options] <main_config_file>\n"
      << "\nOptions:\n"
      << "  -v, --verify-config         Verify all configuration data.\n"
      << "  -s, --test-scheduling       Shows projected/recommended check\n"
      << "                              scheduling and other diagnostic info\n"
      << "                              based on the current configuration\n"
      << "                              files.\n"
      << "  -x, --dont-verify-paths     Don't check for circular object paths -\n"
      << "                              USE WITH CAUTION !\n"
      << "  -p, --precache-objects      Precache object configuration - use with\n"
      << "                              -v or -s options.\n"
      << "  -u, --use-precached-objects Use precached object config file.";
    exit(ERROR);
  }

  // Config file is last argument specified.
  config_file = my_strdup(argv[optind]);

  // Make sure the config file uses an absolute path.
  if (config_file[0] != '/') {
    // Get absolute path of current working directory.
    std::string buffer(qPrintable(QDir::currentPath()));

    // Append a forward slash.
    buffer.append("/");

    // Append the config file to the path.
    buffer.append(config_file);
    delete[] config_file;
    config_file = my_strdup(buffer.c_str());
  }

  // We're just verifying the configuration.
  int result = ERROR;
  if (TRUE == verify_config) {
    // Reset program variables.
    reset_variables();

    // Read in the configuration files (main config file,
    // resource and object config files).
    try {
      // Read main config file.
      logger(log_info_message, basic) << "reading main config file";
      config.parse(config_file);

      // Read object config files.
      if ((result = read_all_object_data(config_file)) == OK)
        result = OK;
      else
        result = ERROR;
    }
    catch(std::exception const &e) {
      logger(log_config_error, basic)
        << "error while processing a config file: " << e.what();
      result = ERROR;
    }

    // There was a problem reading the config files.
    if (result != OK)
      logger(log_config_error, basic)
        << "\n    One or more problems occurred while processing the config files.\n\n"
        << ERROR_CONFIGURATION;
    // The config files were okay, so run the pre-flight check.
    else {
      logger(log_info_message, basic)
        << "running pre-flight check on configuration data";
      result = pre_flight_check();
      if (result != OK)
        logger(log_config_error, basic)
          << "\n    One or more problem occurred during the pre-flight check.\n\n"
          << ERROR_CONFIGURATION;
    }

    // Clean up after ourselves.
    cleanup();

    // Free config_file.
    delete[] config_file;

    // Exit.
    exit(result ? EXIT_FAILURE : EXIT_SUCCESS);
  }

  // We're just testing scheduling.
  else if (TRUE == test_scheduling) {

    // Reset program variables.
    reset_variables();

    // Read in the configuration files (main config file and all host config files).
    try {
      config.parse(config_file);
      apply_log.apply(config);
      engine::instance().add_object(engine::obj_info(QSharedPointer<logging::broker>(new logging::broker),
                                                     log_all,
                                                     basic));

      // Read object config files.
      result = read_all_object_data(config_file);
    }
    catch(std::exception const &e) {
      logger(log_config_error, basic)
        << "error while processing a config file: " << e.what();
    }

    // Read initial service and host state information.
    if (result == OK) {
      initialize_retention_data(config_file);
      read_initial_state_information();
    }

    if (result != OK) {
      logger(log_config_error, basic)
        << "\n    One or more problems occurred while processing the config files.\n";
    }

    // Run the pre-flight check to make sure everything looks okay.
    if ((OK == result) && ((result = pre_flight_check()) != OK)) {
      logger(log_config_error, basic)
        << "\n    One or more problems occurred during the pre-flight check.\n";
    }

    if (OK == result) {
      // Initialize the event timing loop.
      init_timing_loop();

      // Display scheduling information.
      display_scheduling_info();

      if (precache_objects == TRUE)
        logger(log_info_message, basic)
          << "\n"
          << "OBJECT PRECACHING\n"
          << "-----------------\n"
          << "Object config files were precached.";
    }

#undef TEST_TIMEPERIODS
#ifdef TEST_TIMEPERIODS
    /* DO SOME TIMEPERIOD TESTING - ADDED 08/11/2009 */
    time_t now, pref_time, valid_time;
    timeperiod* tp;
    tp = find_timeperiod("247_exclusion");
    time(&now);
    pref_time = now;
    get_next_valid_time(pref_time, &valid_time, tp);
    printf("=====\n");
    printf("CURRENT:   %lu = %s", (unsigned long)now, ctime(&now));
    printf("PREFERRED: %lu = %s", (unsigned long)pref_time, ctime(&pref_time));
    printf("NEXT:      %lu = %s", (unsigned long)valid_time, ctime(&valid_time));
    printf("=====\n");
#endif

    // Clean up after ourselves.
    cleanup();

    // Exit.
    exit(result ? EXIT_FAILURE : EXIT_SUCCESS);
  }

  // Else start to monitor things.
  else {
    char* buffer;
    // Keep monitoring things until we get a shutdown command.
    do {
      // Reset program variables.
      reset_variables();

      // Read in the configuration files (main
      // and resource config files).
      try {
        config.parse(config_file);
        apply_log.apply(config);
        result = OK;
      }
      catch(std::exception const &e) {
        logger(log_config_error, basic)
          << "error while processing a config file: " << e.what();
      }

      /* NOTE 11/06/07 EG moved to after we read config files, as user may have overridden timezone offset */
      /* get program (re)start time and save as macro */
      program_start = time(NULL);
      delete[] mac->x[MACRO_PROCESSSTARTTIME];
      try {
        mac->x[MACRO_PROCESSSTARTTIME] = obj2pchar<unsigned long>(program_start);
      }
      catch (...) {
        cleanup();
        throw ;
      }

      // Initialize modules.
      neb_init_modules();
      neb_init_callback_list();
      try {
        com::centreon::engine::broker::loader& loader(
          com::centreon::engine::broker::loader::instance());
        loader.set_directory(config.get_broker_module_directory());
        loader.load();
      }
      catch (std::exception const& e) {
        logger(log_info_message, basic)
          << "event broker module initialization failed";
        result = ERROR;
      }

      // This must be logged after we read config data, as user may have changed location of main log file.
      logger(log_process_info, basic) << "Centreon Engine "
        << ENGINE_VERSION << " starting ... (PID=" << getpid() << ")";

      // Log the local time - may be different than clock time due to timezone offset.
      now = time(NULL);
      tm = localtime_r(&now, &tm_s);
      strftime(datestring, sizeof(datestring), "%a %b %d %H:%M:%S %Z %Y", tm);
      logger(log_process_info, basic) << "Local time is " << datestring;

      // Write log version/info.
      logger(log_process_info, basic) <<  "LOG VERSION: " << LOG_VERSION_2;

      // Load modules.
      neb_load_all_modules();

      // Send program data to broker.
      broker_program_state(NEBTYPE_PROCESS_PRELAUNCH,
                           NEBFLAG_NONE,
                           NEBATTR_NONE,
                           NULL);

      // Read in all object config data.
      if (result == OK)
        result = read_all_object_data(config_file);

      // There was a problem reading the config files.
      if (result != OK)
        logger(log_process_info | log_runtime_error | log_config_error, basic)
          << "Bailing out due to one or more errors encountered in the configuration files. "
          << "Run Centreon Engine from the command line with the -v option to verify your config before restarting. (PID=" << getpid() << ")";
      // Run the pre-flight check to make sure everything looks okay.
      else if ((result = pre_flight_check()) != OK)
        logger(log_process_info | log_runtime_error | log_verification_error, basic)
          << "Bailing out due to errors encountered while running the pre-flight check.  "
          << "Run Centreon Engine from the command line with the -v option to verify your config before restarting. (PID=" << getpid() << ")";

      // An error occurred that prevented us from (re)starting.
      if (result != OK) {
        // If we were restarting, we need to cleanup from the previous run.
        if (sigrestart == TRUE) {
          // Clean up the status data.
          cleanup_status_data(config_file, TRUE);
        }

        // Send program data to broker.
        broker_program_state(NEBTYPE_PROCESS_SHUTDOWN,
                             NEBFLAG_PROCESS_INITIATED,
                             NEBATTR_SHUTDOWN_ABNORMAL,
                             NULL);
        cleanup();
        exit(ERROR);
      }

      // Handle signals (interrupts).
      setup_sighandler();

      // Send program data to broker.
      broker_program_state(NEBTYPE_PROCESS_START,
                           NEBFLAG_NONE,
                           NEBATTR_NONE,
                           NULL);

      // Initialize status data unless we're starting.
      if (sigrestart == FALSE)
        initialize_status_data(config_file);

      // Read initial service and host state information.
      initialize_retention_data(config_file);
      read_initial_state_information();

      // Initialize comment data.
      initialize_comment_data(config_file);

      // Initialize scheduled downtime data.
      initialize_downtime_data(config_file);

      // Initialize performance data.
      initialize_performance_data(config_file);

      // Initialize the event timing loop.
      init_timing_loop();

      // Initialize check statistics.
      init_check_stats();

      // Update all status data (with retained information).
      update_all_status_data();

      // Log initial host and service state.
      log_host_states(INITIAL_STATES, NULL);
      log_service_states(INITIAL_STATES, NULL);

      // Reset the restart flag.
      sigrestart = FALSE;

      // Send program data to broker.
      broker_program_state(NEBTYPE_PROCESS_EVENTLOOPSTART,
                           NEBFLAG_NONE,
                           NEBATTR_NONE,
                           NULL);

      // Get event start time and save as macro.
      event_start = time(NULL);
      delete[] mac->x[MACRO_EVENTSTARTTIME];
      try {
        mac->x[MACRO_EVENTSTARTTIME] = obj2pchar<unsigned long>(event_start);
      }
      catch(...) {
        // Send program data to broker.
        broker_program_state(NEBTYPE_PROCESS_SHUTDOWN,
                             NEBFLAG_PROCESS_INITIATED,
                             NEBATTR_SHUTDOWN_ABNORMAL,
                             NULL);
        cleanup();
      }

      /***** Start monitoring all services. *****/
      // (doesn't return until a restart or shutdown signal is encountered).
      event_execution_loop();

      /* 03/01/2007 EG Moved from sighandler() to prevent FUTEX locking problems under NPTL */
      // Did we catch a signal ?
      if (caught_signal == TRUE) {
        if (sig_id == SIGHUP) {
          try {
            buffer = my_strdup("Caught SIGHUP, restarting ...");
          }
          catch(...) {
            // Send program data to broker.
            broker_program_state(NEBTYPE_PROCESS_SHUTDOWN,
                                 NEBFLAG_PROCESS_INITIATED,
                                 NEBATTR_SHUTDOWN_ABNORMAL,
                                 NULL);
            cleanup();
          }
        }
        else {
          try {
            std::ostringstream oss;
            oss << "Caught SIG" << sigs[sig_id] << ", shutting down ...";
            buffer = my_strdup(oss.str().c_str());
          }
          catch(...) {
            // Send program data to broker.
            broker_program_state(NEBTYPE_PROCESS_SHUTDOWN,
                                 NEBFLAG_PROCESS_INITIATED,
                                 NEBATTR_SHUTDOWN_ABNORMAL,
                                 NULL);
            cleanup();
          }
        }

        logger(log_process_info, basic) << buffer;
        delete[] buffer;
      }

      // Send program data to broker.
      broker_program_state(NEBTYPE_PROCESS_EVENTLOOPEND,
                           NEBFLAG_NONE,
                           NEBATTR_NONE,
                           NULL);
      if (sigshutdown == TRUE)
        broker_program_state(NEBTYPE_PROCESS_SHUTDOWN,
                             NEBFLAG_USER_INITIATED,
                             NEBATTR_SHUTDOWN_NORMAL,
                             NULL);
      else if (sigrestart == TRUE)
        broker_program_state(NEBTYPE_PROCESS_RESTART,
                             NEBFLAG_USER_INITIATED,
                             NEBATTR_RESTART_NORMAL,
                             NULL);

      // Save service and host state information.
      save_state_information(FALSE);
      cleanup_retention_data(config_file);

      // Clean up performance data.
      cleanup_performance_data(config_file);

      // Clean up the scheduled downtime data.
      cleanup_downtime_data(config_file);

      // Clean up the comment data.
      cleanup_comment_data(config_file);

      // Clean up the status data unless we're restarting.
      if (sigrestart == FALSE)
        cleanup_status_data(config_file, TRUE);

      // Shutdown stuff.
      if (sigshutdown == TRUE) {
        // Log a shutdown message.
        logger(log_process_info, basic)
          << "Successfully shutdown ... (PID=" << getpid() << ")";
      }

      // Clean up after ourselves.
      cleanup();

    } while (sigrestart == TRUE && sigshutdown == FALSE);

    // Free misc memory.
    delete[] config_file;
  }

  return (OK);
}
