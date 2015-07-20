# Basics
#
FROM durdn/atlassian-base
MAINTAINER Nicola Paolucci <npaolucci@atlassian.com>

# Install Jira

RUN apt-get update
RUN apt-get remove oracle-java7-installer -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install oracle-java6-installer -y

ENV JIRA_VERSION 3.12.3
RUN curl -Lks https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-standard-${JIRA_VERSION}-standalone.tar.gz -o /root/jira.tar.gz && \
 /usr/sbin/useradd --create-home --home-dir /opt/jira --groups atlassian --shell /bin/bash jira && \
 tar zxf /root/jira.tar.gz --strip=1 -C /opt/jira && \
 chown -R jira:jira /opt/atlassian-home && \
 chown -R jira:jira /opt/jira && \
 mv /opt/jira/conf/server.xml /opt/jira/conf/server-backup.xml

ENV CONTEXT_PATH ROOT
ADD launch.bash /launch

# Launching Jira

WORKDIR /opt/jira
VOLUME ["/opt/atlassian-home"]
EXPOSE 8080
USER jira
CMD ["/launch"]
