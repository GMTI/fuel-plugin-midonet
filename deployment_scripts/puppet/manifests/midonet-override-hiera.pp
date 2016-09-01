#    Copyright 2016 Midokura, SARL.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
notice('MODULAR: midonet-override-hiera.pp')

$midonet_settings = hiera('midonet-fuel-plugin')
$mem = $midonet_settings['mem']

file {'/etc/hiera/plugins/midonet-fuel-plugin.yaml':
    ensure => file,
    source => '/etc/fuel/plugins/midonet-fuel-plugin-5.0/puppet/files/midonet-fuel-plugin.yaml'
}

if $mem == false {
    # MidoNet 2015.06 OSS does not support fernet tokens
    file_line {'token_provider':
        path => '/etc/hiera/plugins/midonet-fuel-plugin.yaml',
        line => 'token_provider: uuid'
    }
}