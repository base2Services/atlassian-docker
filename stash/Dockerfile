# Basics
#
FROM ubuntu:12.04
MAINTAINER Nicola Paolucci <npaolucci@atlassian.com>
RUN apt-get update
RUN apt-get install -q -y git-core

# Install Java 7

RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y software-properties-common
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y python-software-properties
RUN DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get install oracle-java7-installer -y

# Install Stash

RUN apt-get install -q -y curl
RUN curl -Lks http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-2.12.1.tar.gz -o /root/stash.tar.gz
RUN mkdir -p /opt/stash
RUN tar zxf /root/stash.tar.gz --strip=1 -C /opt/stash
RUN mkdir -p /opt/stash-home
RUN sed -i -e "s/^#!\/bin\/sh/#!\/bin\/bash/" /opt/stash/bin/catalina.sh

ADD launch.bash /launch

# Launching Stash

WORKDIR /opt/stash-home
EXPOSE 7990
CMD ["/opt/stash/bin/start-stash.sh", "-fg"]
