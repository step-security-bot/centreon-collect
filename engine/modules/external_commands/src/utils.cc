/*
** Copyright 2011-2013 Merethis
** Copyright 2020-2021 Centreon
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

#include "com/centreon/engine/modules/external_commands/utils.hh"
#include "com/centreon/engine/commands/processing.hh"
#include "com/centreon/engine/common.hh"
#include "com/centreon/engine/globals.hh"
#include "com/centreon/engine/log_v2.hh"
#include "com/centreon/engine/logging/logger.hh"
#include "com/centreon/engine/string.hh"
#include "nagios.h"

using namespace com::centreon::engine;
using namespace com::centreon::engine::logging;

static int command_file_fd = -1;
static int command_file_created = false;
static FILE* command_file_fp = NULL;

static std::unique_ptr<std::thread> worker;
static std::atomic_bool should_exit{false};

/* creates external command file as a named pipe (FIFO) and opens it for reading
 * (non-blocked mode) */
int open_command_file(void) {
  struct stat st;

  /* if we're not checking external commands, don't do anything */
  if (config->check_external_commands() == false)
    return OK;

  /* the command file was already created */
  if (command_file_created)
    return OK;

  /* reset umask (group needs write permissions) */
  umask(S_IWOTH);

  /* use existing FIFO if possible */
  if (!(stat(config->command_file().c_str(), &st) != -1 &&
        (st.st_mode & S_IFIFO))) {
    /* create the external command file as a named pipe (FIFO) */
    if (mkfifo(config->command_file().c_str(),
               S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP) != 0) {
      engine_logger(log_runtime_error, basic)
          << "Error: Could not create external command file '"
          << config->command_file() << "' as named pipe: (" << errno << ") -> "
          << strerror(errno)
          << ".  If this file already exists and "
             "you are sure that another copy of Centreon Engine is not "
             "running, "
             "you should delete this file.";
      log_v2::runtime()->error(
          "Error: Could not create external command file '{}' as named pipe: "
          "({}) -> {}.  If this file already exists and "
          "you are sure that another copy of Centreon Engine is not "
          "running, "
          "you should delete this file.",
          config->command_file(), errno, strerror(errno));
      return ERROR;
    }
  }

  /* open the command file for reading (non-blocked) - O_TRUNC flag cannot be
   * used due to errors on some systems */
  /* NOTE: file must be opened read-write for poll() to work */
  if ((command_file_fd =
           open(config->command_file().c_str(), O_RDWR | O_NONBLOCK)) < 0) {
    engine_logger(log_runtime_error, basic)
        << "Error: Could not open external command file for reading "
           "via open(): ("
        << errno << ") -> " << strerror(errno);
    log_v2::runtime()->error(
        "Error: Could not open external command file for reading "
        "via open(): ({}) -> {}",
        errno, strerror(errno));
    return ERROR;
  }

  /* Set the close-on-exec flag on the file descriptor. */
  {
    int flags;
    flags = fcntl(command_file_fd, F_GETFL);
    if (flags < 0) {
      engine_logger(log_runtime_error, basic)
          << "Error: Could not get file descriptor flags on external "
             "command via fcntl(): ("
          << errno << ") -> " << strerror(errno);
      log_v2::runtime()->error(
          "Error: Could not get file descriptor flags on external "
          "command via fcntl(): ({}) -> {}",
          errno, strerror(errno));
      return ERROR;
    }
    flags |= FD_CLOEXEC;
    if (fcntl(command_file_fd, F_SETFL, flags) == -1) {
      engine_logger(log_runtime_error, basic)
          << "Error: Could not set close-on-exec flag on external "
             "command via fcntl(): ("
          << errno << ") -> " << strerror(errno);
      log_v2::runtime()->error(
          "Error: Could not set close-on-exec flag on external "
          "command via fcntl(): ({}) -> {}",
          errno, strerror(errno));
      return ERROR;
    }
  }

  /* re-open the FIFO for use with fgets() */
  if ((command_file_fp = (FILE*)fdopen(command_file_fd, "r")) == NULL) {
    engine_logger(log_runtime_error, basic)
        << "Error: Could not open external command file for "
           "reading via fdopen(): ("
        << errno << ") -> " << strerror(errno);
    log_v2::runtime()->error(
        "Error: Could not open external command file for "
        "reading via fdopen(): ({}) -> {}",
        errno, strerror(errno));
    return ERROR;
  }

  /* initialize worker thread */
  if (init_command_file_worker_thread() == ERROR) {
    engine_logger(log_runtime_error, basic)
        << "Error: Could not initialize command file worker thread.";
    log_v2::runtime()->error(
        "Error: Could not initialize command file worker thread.");
    /* close the command file */
    fclose(command_file_fp);

    /* delete the named pipe */
    unlink(config->command_file().c_str());

    return ERROR;
  }

  /* set a flag to remember we already created the file */
  command_file_created = true;

  return OK;
}

/* closes the external command file FIFO and deletes it */
int close_command_file(void) {
  /* if we're not checking external commands, don't do anything */
  if (config->check_external_commands() == false)
    return OK;

  /* the command file wasn't created or was already cleaned up */
  if (command_file_created == false)
    return OK;

  /* reset our flag */
  command_file_created = false;

  /* close the command file */
  fclose(command_file_fp);

  return OK;
}

/* worker thread - artificially increases buffer of named pipe */
static void command_file_worker_thread() {
  log_v2::external_command()->info("start command_file_worker_thread");

  char input_buffer[MAX_EXTERNAL_COMMAND_LENGTH];
  struct pollfd pfd;
  int pollval;
  struct timeval tv;

  while (!should_exit) {
    pthread_testcancel();

    /* wait for data to arrive */
    /* select seems to not work, so we have to use poll instead */
    /* 10-15-08 EG check into implementing William's patch @
     * http://blog.netways.de/2008/08/15/nagios-unter-mac-os-x-installieren/ */
    /* 10-15-08 EG poll() seems broken on OSX - see Jonathan's patch a few lines
     * down */
    pfd.fd = command_file_fd;
    pfd.events = POLLIN;
    pollval = poll(&pfd, 1, 500);

    /* loop if no data */
    if (pollval == 0)
      continue;

    /* check for errors */
    if (pollval == -1) {
      switch (errno) {
        case EBADF:
          engine_logger(logging_options, basic)
              << "command_file_worker_thread(): poll(): EBADF";
          log_v2::external_command()->info(
              "command_file_worker_thread(): poll(): EBADF");
          break;

        case ENOMEM:
          engine_logger(logging_options, basic)
              << "command_file_worker_thread(): poll(): ENOMEM";
          log_v2::external_command()->info(
              "command_file_worker_thread(): poll(): ENOMEM");
          break;

        case EFAULT:
          engine_logger(logging_options, basic)
              << "command_file_worker_thread(): poll(): EFAULT";
          log_v2::external_command()->info(
              "command_file_worker_thread(): poll(): EFAULT");
          break;

        case EINTR:
          /* this can happen when running under a debugger like gdb */
          /*
            write_to_log("command_file_worker_thread(): poll(): EINTR
            (impossible)",logging_options,NULL);
          */
          break;

        default:
          engine_logger(logging_options, basic)
              << "command_file_worker_thread(): poll(): Unknown errno value.";
          log_v2::external_command()->info(
              "command_file_worker_thread(): poll(): Unknown errno value.");
          break;
      }

      continue;
    }

    /* 10-15-08 Fix for OS X by Jonathan Saggau - see
     * http://www.jonathansaggau.com/blog/2008/09/using_shark_and_custom_dtrace.html
     */
    /* Not sure if this would have negative effects on other OSes... */
    if (external_command_buffer.empty()) {
      /* pause a bit so OS X doesn't go nuts with CPU overload */
      tv.tv_sec = 0;
      tv.tv_usec = 500;
      select(0, nullptr, nullptr, nullptr, &tv);
    }

    external_command_buffer.set_capacity(
        config->external_command_buffer_slots());

    /* process all commands in the file (named pipe) if there's some space in
     * the buffer */
    if (!external_command_buffer.full()) {
      /* clear EOF condition from prior run (FreeBSD fix) */
      /* FIXME: use_poll_on_cmd_pipe: Still needed? */
      clearerr(command_file_fp);

      /* read and process the next command in the file */
      while (!should_exit &&
             fgets(input_buffer, (int)(sizeof(input_buffer) - 1),
                   command_file_fp) != nullptr) {
        // Check if command is thread-safe (for immediate execution).
        if (commands::processing::is_thread_safe(input_buffer)) {
          log_v2::external_command()->debug("direct execute {}", input_buffer);
          commands::processing::execute(input_buffer);
        }
        // Submit the external command for processing
        // (retry if buffer is full).
        else {
          while (!should_exit && external_command_buffer.full()) {
            // Wait a bit.
            tv.tv_sec = 0;
            tv.tv_usec = 250000;
            select(0, nullptr, nullptr, nullptr, &tv);
          }
          log_v2::external_command()->debug("push execute {}", input_buffer);
          external_command_buffer.push(input_buffer);
          // Bail if the circular buffer is full.
          if (external_command_buffer.full())
            break;
        }
      }
    }
  }
  log_v2::external_command()->info("end command_file_worker_thread");
}

/* initializes command file worker thread */
int init_command_file_worker_thread(void) {
  /* initialize circular buffer */
  external_command_buffer.clear();

  /* create worker thread */
  worker = std::make_unique<std::thread>(&command_file_worker_thread);
  pthread_setname_np(worker->native_handle(), "command_file_worker_thread");

  return OK;
}

/* shutdown command file worker thread */
int shutdown_command_file_worker_thread(void) {
  if (!should_exit) {
    /* tell the worker thread to exit */
    should_exit = true;

    /* wait for the worker thread to exit */
    if (worker && worker->joinable())
      worker->join();
  }

  return OK;
}