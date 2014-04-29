# Puppet agent
class puppet::agent {
  class { '::puppet::agent::install': } ->
  class { '::puppet::agent::config': } ~>
  class { '::puppet::agent::service': } ->
  Class['::puppet::agent']

  Class['puppet::config'] ~> Class['puppet::agent::service']
}
