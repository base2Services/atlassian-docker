# Basics
#
FROM durdn/atlassian-base
MAINTAINER Nicola Paolucci <npaolucci@atlassian.com>

# Install Jira

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
EXPOSE 8080
USER jira
CMD ["/launch"]
