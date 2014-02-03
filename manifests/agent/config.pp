class puppet::agent::config {
  concat_fragment { 'puppet.conf+20-agent':
    content => template($puppet::agent_template),
  }
  
  if $::puppet::runmode == 'service' and $::osfamily == 'Debian'{
    augeas {'puppet::set_start':
      context => "/files/etc/default/puppet",
      changes => "set START yes",
    }
  }
}
