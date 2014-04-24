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

RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y curl sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y xmlstarlet
RUN curl -Lks http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-2.12.1.tar.gz -o /root/stash.tar.gz
RUN /usr/sbin/useradd --create-home --home-dir /opt/stash --shell /bin/bash stash
RUN tar zxf /root/stash.tar.gz --strip=1 -C /opt/stash
RUN mkdir -p /opt/stash-home
RUN sed -i -e "s/^#!\/bin\/sh/#!\/bin\/bash/" /opt/stash/bin/catalina.sh
RUN mv /opt/stash/conf/server.xml /opt/stash/conf/server-backup.xml
RUN chown -R stash:stash /opt/stash

ENV CONTEXT_PATH ROOT
ADD launch.bash /launch

ADD own-volume.sh /usr/local/bin/own-volume
RUN echo "stash ALL=NOPASSWD: /usr/local/bin/own-volume" >> /etc/sudoers

# Launching Stash

WORKDIR /opt/stash
VOLUME /opt/stash-home
EXPOSE 7990 7999
USER stash
CMD ["/launch"]
