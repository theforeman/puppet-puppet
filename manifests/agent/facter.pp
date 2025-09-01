# Puppet agent facter configuration
# @api private
class puppet::agent::facter inherits puppet::config {
  puppet::config::agent::facter {
    'blocklist': value => $puppet::config::facter_blocklist;
    'cachelist': value => $puppet::config::facter_cachelist;
    'cache_ttl': value => $puppet::config::cache_ttl;
  }

    if versioncmp(fact('aio_agent_version'),'7') >= 0 {
    file { '/etc/puppetlabs/facter':
      ensure => directory,
    }

        Hocon_setting {
      path    => '/etc/puppetlabs/facter/facter.conf',
      require => File['/etc/puppetlabs/facter'],
    }


        if $facts['blocklist'] {
      hocon_setting { 'blocklist facts group':
        ensure  => present,
        setting => 'fact-groups.blocked-facts',
        value   => $facts['blocklist'],
        type    => 'array',
      }
      -> hocon_setting { 'blocklist facts':
        ensure  => present,
        setting => 'facts.blocklist',
        value   => ['blocked-facts'],
        type    => 'array',
      }
    } else {
      hocon_setting { 'blocklist facts group':
        ensure  => absent,
        setting => 'fact-groups.blocked-facts',
      }
      hocon_setting { 'blocklist facts':
        ensure  => absent,
        setting => 'facts.blocklist',
      }
    }
    if $facts['cachelist'] {
      hocon_setting { 'cachelist facts group':
        ensure  => present,
        setting => 'fact-groups.cached-facts',
        value   => $facts['cachelist'],
        type    => 'array',
      }
      -> hocon_setting { 'cachelist facts':
        ensure  => present,
        setting => 'facts.ttls',
        value   => [{'cached-facts' => $facts['cache_ttl'] }],
        type    => 'array',
      }
    } else {
      hocon_setting { 'cachelist facts group':
        ensure  => absent,
        setting => 'fact-groups.cached-facts',
      }
      hocon_setting { 'cachelist facts':
        ensure  => absent,
        setting => 'facts.ttls',
      }
    }
  }
}

