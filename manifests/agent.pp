# Puppet agent
# @api private
class puppet::agent {
  contain puppet::agent::install
  contain puppet::agent::config
  contain puppet::agent::service

  if $puppet::facter_config.length > 0 {
    contain puppet::agent::facter
    Class['puppet::agent::install'] -> Class['puppet::agent::facter']
  }

  Class['puppet::agent::install'] -> Class['puppet::agent::config', 'puppet::agent::service']
  Class['puppet::config', 'puppet::agent::config'] ~> Class['puppet::agent::service']
}
