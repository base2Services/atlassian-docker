# Basics
#
from base:latest
maintainer Nicola Paolucci <npaolucci@atlassian.com>
run apt-get update
run apt-get install -q -y git-core

# Install Java 7

run DEBIAN_FRONTEND=noninteractive apt-get install -q -y software-properties-common
run DEBIAN_FRONTEND=noninteractive apt-get install -q -y python-software-properties
run DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:webupd8team/java -y
run apt-get update
run echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
run DEBIAN_FRONTEND=noninteractive apt-get install oracle-java7-installer -y

# Install Crowd

run apt-get install -q -y curl
run curl -Lks http://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-2.7.0.tar.gz -o /root/crowd.tar.gz
run /usr/sbin/useradd --create-home --home-dir /usr/local/crowd --shell /bin/bash crowd
run mkdir -p /opt/crowd
run tar zxf /root/crowd.tar.gz --strip=1 -C /opt/crowd
run mkdir -p /opt/crowd-home
run echo "crowd.home = /opt/crowd-home" > /opt/crowd/crowd-webapp/WEB-INF/classes/crowd-init.properties

# Launching Crowd

workdir /opt/crowd
expose 8095:8095
cmd /opt/crowd/apache-tomcat/bin/catalina.sh run
