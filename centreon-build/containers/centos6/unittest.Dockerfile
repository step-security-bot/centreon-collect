FROM monitoring-dependencies:centos6
MAINTAINER Matthieu Kermagoret <mkermagoret@centreon.com>
COPY build-dependencies.txt /usr/share/monitoring/build-dependencies.txt
RUN yum install -y `cat /usr/share/monitoring/build-dependencies.txt`
