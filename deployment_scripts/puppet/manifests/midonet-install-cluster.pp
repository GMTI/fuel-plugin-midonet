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
notice('MODULAR: midonet-install-cluster.pp')

# Extract data from hiera
$network_metadata     = hiera_hash('network_metadata')
$controllers_map      = get_nodes_hash_by_roles($network_metadata, ['controller', 'primary-controller'])
$controllers_mgmt_ips = get_node_to_ipaddr_map_by_network_role($controllers_map, 'management')
$nsdb_hash            = get_nodes_hash_by_roles($network_metadata, ['nsdb'])
$nsdb_mgmt_ips        = get_node_to_ipaddr_map_by_network_role($nsdb_hash, 'management')
$zoo_ips_hash         = generate_api_zookeeper_ips(values($nsdb_mgmt_ips))
$management_vip       = hiera('management_vip')
$public_vip           = hiera('public_vip')
$keystone_data        = hiera_hash('keystone')
$access_data          = hiera_hash('access')
$public_ssl_hash      = hiera('public_ssl')
$shared_secret        = hiera('neutron_metadata_proxy_secret')

class {'::midonet::cluster':
  zk_server_list       => values($nsdb_mgmt_ips),
  management_vip       => $management_vip,
  shared_secret        => $shared_secret,
  keystone_admin_token => $keystone_data['admin_token']
}

# HA proxy configuration
Haproxy::Service        { use_include   => true }
Haproxy::Balancermember { use_include => true }

Openstack::Ha::Haproxy_service {
  server_names        => keys($controllers_mgmt_ips),
  ipaddresses         => values($controllers_mgmt_ips),
  public_virtual_ip   => $public_vip,
  internal_virtual_ip => $management_vip
}

openstack::ha::haproxy_service { 'midonet-api':
  order                  => 199,
  listen_port            => 8181,
  balancermember_port    => 8181,
  define_backups         => true,
  before_start           => true,
  public                 => true,
  haproxy_config_options => {
    'balance'        => 'roundrobin',
    'option'         => ['httplog'],
  },
  balancermember_options => 'check',
}

exec { 'haproxy reload':
  command   => 'export OCF_ROOT="/usr/lib/ocf"; (ip netns list | grep haproxy) && ip netns exec haproxy /usr/lib/ocf/resource.d/fuel/ns_haproxy reload',
  path      => '/usr/bin:/usr/sbin:/bin:/sbin',
  logoutput => true,
  provider  => 'shell',
  tries     => 10,
  try_sleep => 10,
  returns   => [0, ''],
}

Haproxy::Listen <||> -> Exec['haproxy reload']
Haproxy::Balancermember <||> -> Exec['haproxy reload']

class { 'firewall': }

firewall {'502 Midonet api':
  port => '8181',
  proto => 'tcp',
  action => 'accept',
}