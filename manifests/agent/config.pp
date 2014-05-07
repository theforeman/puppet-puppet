# Puppet agent configuration
class puppet::agent::config {
  concat_fragment { 'puppet.conf+20-agent':
    content => template($puppet::agent_template),
  }

  if $::puppet::runmode == 'service' {
    $should_start = 'yes'
  } else {
    $should_start = 'no'
  }

  if $::osfamily == 'Debian' {
    augeas {'puppet::set_start':
      context => '/files/etc/default/puppet',
      changes => "set START ${should_start}",
      incl    => '/etc/default/puppet',
      lens    => 'Shellvars.lns',
    }
    file {'/var/lib/puppet/state/agent_disabled.lock':
      ensure => absent
    }
  }
}
