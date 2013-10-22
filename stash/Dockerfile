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

# Install Stash

run apt-get install -q -y curl
run curl -Lks http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-2.8.2.tar.gz -o /root/stash.tar.gz
run mkdir -p /opt/stash
run tar zxf /root/stash.tar.gz --strip=1 -C /opt/stash
run mkdir -p /opt/stash-home

# Launching Stash

workdir /opt/stash-home
env STASH_HOME /opt/stash-home
expose 7990:7990
cmd ["/opt/stash/bin/start-stash.sh", "-fg"]
