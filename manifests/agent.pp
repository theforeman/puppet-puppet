# Puppet agent
class puppet::agent {
  contain puppet::agent::install
  contain puppet::agent::config
  contain puppet::agent::service

  Class['puppet::agent::install'] ~> Class['puppet::agent::config']
  Class['puppet::config', 'puppet::agent::config'] ~> Class['puppet::agent::service']
}
