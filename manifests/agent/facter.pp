# Puppet agent facter configuration
# @api private
class puppet::agent::facter inherits puppet::params {
  puppet::config::agent::facter {
    'blocklist': value => $puppet::params::facter_blocklist;
    'cachelist': value => $puppet::params::facter_cachelist;
    'cache_ttl': value => $puppet::params::cache_ttl;
  }

    if versioncmp(fact('aio_agent_version'),'7') >= 0 {
    file { '/etc/puppetlabs/facter':
      ensure => directory,
    }

        Hocon_setting {
      path    => '/etc/puppetlabs/facter/facter.conf',
      require => File['/etc/puppetlabs/facter'],
    }


        if $puppet::params::blocklist {
      hocon_setting { 'blocklist facts group':
        ensure  => present,
        setting => 'fact-groups.blocked-facts',
        value   => $puppet::params::blocklist,
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
    if $puppet::params::cachelist {
      hocon_setting { 'cachelist facts group':
        ensure  => present,
        setting => 'fact-groups.cached-facts',
        value   => $puppet::params::cachelist,
        type    => 'array',
      }
      -> hocon_setting { 'cachelist facts':
        ensure  => present,
        setting => 'facts.ttls',
        value   => [{'cached-facts' => $puppet::params::cache_ttl }],
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

