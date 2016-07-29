#!/bin/bash

puppet module install ripienaar-module_data --version=0.0.3 --force

puppet module install puppetlabs-java --version=1.4.1 --ignore-dependencies --force

#################################
#puppet module install midonet-cassandra --version=1.0.4 --ignore-dependencies --force
# FIXME, this is temporarily done via midonet-define-repositories.pp
#(cd /etc/puppet/modules && git clone https://github.com/GMTI/puppet-cassandra cassandra)
#################################

puppet module install deric-zookeeper --version=0.3.9 --ignore-dependencies --force

#puppet module install puppetlabs-tomcat --version=1.3.2 --ignore-dependencies --force

#################################
#puppet module install midonet-midonet --version=2015.6.7 --ignore-dependencies --force
# FIXME, this is temporarily done via midonet-define-repositories.pp
#(cd /etc/puppet/modules && git clone -b nectar/liberty https://github.com/GMTI/puppet-midonet midonet)
#################################

gem install faraday  # This is needed by the midonet providers
