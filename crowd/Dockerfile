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

# Install Crowd

RUN apt-get install -q -y curl
RUN curl -Lks http://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-2.7.0.tar.gz -o /root/crowd.tar.gz
RUN /usr/sbin/useradd --create-home --home-dir /usr/local/crowd --shell /bin/bash crowd
RUN mkdir -p /opt/crowd
RUN tar zxf /root/crowd.tar.gz --strip=1 -C /opt/crowd
RUN mkdir -p /opt/crowd-home
RUN echo "crowd.home = /opt/crowd-home" > /opt/crowd/crowd-webapp/WEB-INF/classes/crowd-init.properties

# Launching Crowd

WORKDIR /opt/crowd
EXPOSE 8095
CMD /opt/crowd/apache-tomcat/bin/catalina.sh run
