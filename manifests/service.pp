# Set up the puppet client as a service
class puppet::service {
  service {'puppet':
    name    => $puppet::params::service_name,
    require => Class['puppet::install']
  }
}
