# Set up the puppet client as a service
class puppet::service {
  service {'puppet':
    require => Class['puppet::install']
  }
}
