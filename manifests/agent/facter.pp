# Puppet agent facter configuration
# @api private
class puppet::agent::facter (
  Optional[Array[String]] $blocklist = undef,
  Optional[Array[String]] $cachelist = undef,
  String $cache_ttl = '1 day',
) {
  if versioncmp(fact('aio_agent_version'),'7') >= 0 {
    file { '/etc/puppetlabs/facter':
      ensure => directory,
    }

    hocon_setting { 'facter.conf':
      path    => '/etc/puppetlabs/facter/facter.conf',
      require => File['/etc/puppetlabs/facter'],
    }

    if $blocklist {
      hocon_setting { 'blocklist facts group':
        ensure  => present,
        setting => 'fact-groups.blocked-facts',
        value   => $blocklist,
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
    if $cachelist {
      hocon_setting { 'cachelist facts group':
        ensure  => present,
        setting => 'fact-groups.cached-facts',
        value   => $cachelist,
        type    => 'array',
      }
      -> hocon_setting { 'cachelist facts':
        ensure  => present,
        setting => 'facts.ttls',
        value   => [{ 'cached-facts' => $cache_ttl }],
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
