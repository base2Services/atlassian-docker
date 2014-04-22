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

# Install Jira

RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y curl sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y xmlstarlet
RUN curl -Lks http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.2.3.tar.gz -o /root/jira.tar.gz
RUN /usr/sbin/useradd --create-home --home-dir /opt/jira --shell /bin/bash jira
RUN tar zxf /root/jira.tar.gz --strip=1 -C /opt/jira
RUN mkdir -p /opt/jira-home
RUN chown -R jira:jira /opt/jira-home
RUN echo "jira.home = /opt/jira-home" > /opt/jira/atlassian-jira/WEB-INF/classes/jira-application.properties
RUN chown -R jira:jira /opt/jira
RUN mv /opt/jira/conf/server.xml /opt/jira/conf/server-backup.xml

ENV CONTEXT_PATH ROOT
ADD launch.bash /launch

ADD own-volume.sh /usr/local/bin/own-volume
RUN echo "jira ALL=NOPASSWD: /usr/local/bin/own-volume" >> /etc/sudoers

# Launching Jira

WORKDIR /opt/jira
VOLUME ["/opt/jira-home"]
RUN rm -f /opt/jira-home/.jira-home.lock
EXPOSE 8080
USER jira
CMD ["/launch"]
