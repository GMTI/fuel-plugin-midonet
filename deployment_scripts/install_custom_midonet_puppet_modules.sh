#!/bin/bash

# This is done inside midonet-define-repositories.pp because git package
# is listed as a dependency of this script
#apt-get -y install git

#################################
# FIXME, do this The Right Way (TM)
cat <<-EOF > /etc/apt/sources.list.d/openjdk.list
# OpenJDK 8
deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main
EOF

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x86F44E2A

apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get -y install openjdk-8-jre-headless
#################################

#################################
#puppet module install midonet-cassandra --version=1.0.4 --ignore-dependencies --force
# FIXME, do this The Right Way (TM)
(cd /etc/puppet/modules && rm -rf /etc/puppet/modules/cassandra && git clone -b midonet-5.x https://github.com/GMTI/puppet-cassandra cassandra)
#################################

#################################
#puppet module install midonet-midonet --version=2015.6.7 --ignore-dependencies --force
# FIXME, do this The Right Way (TM)
(cd /etc/puppet/modules && rm -rf /etc/puppet/modules/midonet && git clone -b nectar/liberty https://github.com/GMTI/puppet-midonet midonet)
#################################

