if $::osfamily == 'Debian' {
  tweaks::ubuntu_service_override { 'nova-network':
      package_name => "nova-network",
    }
  package { 'nova-network':
    ensure => installed,
  }
  service { 'nova-network':
    enable => false,
  }
}
