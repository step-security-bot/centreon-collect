/*
** Copyright 2011-2012 Merethis
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

#include <QDir>
#include <QFile>
#include <string.h>
#include "com/centreon/broker/compression/stream.hh"
#include "com/centreon/broker/config/applier/init.hh"
#include "com/centreon/broker/file/stream.hh"
#include "com/centreon/broker/io/exceptions/shutdown.hh"
#include "com/centreon/broker/io/raw.hh"

using namespace com::centreon::broker;

#define TEMP_FILE_NAME "broker_compression_stream_io.tmp"
#include <iostream>
/**
 *  Check that compression works properly.
 *
 *  @return 0 on success.
 */
int main() {
  // Initialization.
  config::applier::init();

  // Generate file name.
  QString filename(QDir::tempPath());
  filename.append("/" TEMP_FILE_NAME);

  // Remove old file.
  QFile::remove(filename);

  // Generate data packet.
  misc::shared_ptr<io::raw> data(new io::raw);
  data->append("0123456789abcdefghijklmnopqrstuvwxyz");

  {
    // Open file for writing.
    misc::shared_ptr<file::stream>
      fs(new file::stream(
                     filename,
                     QIODevice::WriteOnly));
    compression::stream cs(-1, 1000);
    cs.write_to(fs.staticCast<io::stream>());

    // Write data in file.
    for (unsigned int i(0); i < 10000; ++i)
      cs.write(data.staticCast<io::data>());
  }

  // Return value.
  int retval(0);

  // Check file size (check that compression worked).
  {
    QFile f(filename);
    qint64 size(f.size());
    retval = ((size <= 0) || (size >= 360000));
  }

  {
    // Open file for reading.
    misc::shared_ptr<file::stream>
      fs(new file::stream(
                     filename,
                     QIODevice::ReadWrite));
    compression::stream cs(-1);
    cs.read_from(fs.staticCast<io::stream>());

    // Compare data read with data written.
    unsigned int bufferc(0);
    char const buffer[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    data.clear();
    unsigned int datac(0);
    for (unsigned int count(0); !retval && (count < 10000);) {
      // Read data.
      if (data.isNull()) {
        misc::shared_ptr<io::data> d;
        cs.read(d);
        if (d.isNull()
            || ("com::centreon::broker::io::raw" != d->type()))
          retval |= 1;
        else {
          data = d.staticCast<io::raw>();
          datac = 0;
        }
      }

      if (!retval) {
        // Compare data.
        unsigned int cb(((data->size() - datac)
                           < (sizeof(buffer) - 1 - bufferc))
                        ? (data->size() - datac)
                        : (sizeof(buffer) - 1 - bufferc));
        retval |= memcmp(data->QByteArray::data() + datac,
                         buffer + bufferc,
                         cb);

        // Adjust buffers.
        bufferc += cb;
        if (bufferc == (sizeof(buffer) - 1)) {
          ++count;
          bufferc = 0;
        }
        datac += cb;
        if (datac == static_cast<unsigned int>(data->size()))
          data.clear();
      }
    }
    // EOF must be reached.
    try {
      misc::shared_ptr<io::data> d;
      cs.read(d);
      retval |= 1;
    }
    catch (io::exceptions::shutdown const& s) {
      (void)s;
    }
  }

  // Remove temporary file.
  QFile::remove(filename);

  return (retval);
}
