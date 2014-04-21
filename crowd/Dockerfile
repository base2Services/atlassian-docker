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
RUN curl -Lks http://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-2.7.1.tar.gz -o /root/crowd.tar.gz
RUN /usr/sbin/useradd --create-home --home-dir /opt/crowd --shell /bin/bash crowd
RUN tar zxf /root/crowd.tar.gz --strip=1 -C /opt/crowd
RUN mkdir -p /opt/crowd-home
RUN chown -R crowd:crowd /opt/crowd-home
RUN echo "crowd.home = /opt/crowd-home" > /opt/crowd/crowd-webapp/WEB-INF/classes/crowd-init.properties
RUN mv /opt/crowd/apache-tomcat/webapps/ROOT /opt/crowd/splash-webapp
RUN mv /opt/crowd/apache-tomcat/conf/Catalina/localhost /opt/crowd/webapps
RUN mkdir /opt/crowd/apache-tomcat/conf/Catalina/localhost

ENV CROWD_URL http://localhost:8095/crowd
ENV LOGIN_BASE_URL http://localhost:8095

ENV CROWD_CONTEXT crowd
ENV CROWDID_CONTEXT openidserver
ENV OPENID_CLIENT_CONTEXT openidclient
ENV DEMO_CONTEXT demo
ENV SPLASH_CONTEXT ROOT

ADD splash-context.xml /opt/crowd/webapps/splash.xml
RUN chown -R crowd:crowd /opt/crowd
ADD launch.bash /launch

# Launching Crowd

WORKDIR /opt/crowd
EXPOSE 8095
USER crowd
CMD ["/launch"]
