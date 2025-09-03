# Puppet agent facter configuration
# @api private
class puppet::agent::facter (
  Optional[Array[String]] $blocklist = undef,
  Optional[Array[String]] $cachelist = undef,
  String $cache_ttl = '1 day',
) {
  file { '/etc/puppetlabs/facter':
    ensure => directory,
  }

  hocon_setting { 'facter.conf':
    path    => '/etc/puppetlabs/facter/facter.conf',
    require => File['/etc/puppetlabs/facter'],
    setting => 'managed',
    value   => 'puppet',
  }

  if $blocklist {
    hocon_setting { 'blocklist facts group':
      ensure  => present,
      path    => '/etc/puppetlabs/facter/facter.conf',
      setting => 'fact-groups.blocked-facts',
      value   => $blocklist,
      type    => 'array',
    }
    -> hocon_setting { 'blocklist facts':
      ensure  => present,
      path    => '/etc/puppetlabs/facter/facter.conf',
      setting => 'facts.blocklist',
      value   => ['blocked-facts'],
      type    => 'array',
    }
  } else {
    hocon_setting { 'blocklist facts group':
      ensure  => absent,
      path    => '/etc/puppetlabs/facter/facter.conf',
      setting => 'fact-groups.blocked-facts',
    }
    hocon_setting { 'blocklist facts':
      ensure  => absent,
      path    => '/etc/puppetlabs/facter/facter.conf',
      setting => 'facts.blocklist',
    }
  }
  if $cachelist {
    hocon_setting { 'cachelist facts group':
      ensure  => present,
      path    => '/etc/puppetlabs/facter/facter.conf',
      setting => 'fact-groups.cached-facts',
      value   => $cachelist,
      type    => 'array',
    }
    -> hocon_setting { 'cachelist facts':
      ensure  => present,
      path    => '/etc/puppetlabs/facter/facter.conf',
      setting => 'facts.ttls',
      value   => [{ 'cached-facts' => $cache_ttl }],
      type    => 'array',
    }
  } else {
    hocon_setting { 'cachelist facts group':
      ensure  => absent,
      path    => '/etc/puppetlabs/facter/facter.conf',
      setting => 'fact-groups.cached-facts',
    }
    hocon_setting { 'cachelist facts':
      ensure  => absent,
      path    => '/etc/puppetlabs/facter/facter.conf',
      setting => 'facts.ttls',
    }
  }
}
