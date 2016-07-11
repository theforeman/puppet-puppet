# Puppet agent configuration
class puppet::agent::config inherits puppet::config {
  puppet::config::agent{
    'classfile':         value => $::puppet::classfile;
    'localconfig':       value => '$vardir/localconfig';
    'default_schedules': value => false;
    'report':            value => true;
    'pluginsync':        value => $::puppet::pluginsync;
    'masterport':        value => $::puppet::port;
    'environment':       value => $::puppet::environment;
    'certname':          value => $::puppet::client_certname;
    'listen':            value => $::puppet::listen;
    'splay':             value => $::puppet::splay;
    'splaylimit':        value => $::puppet::splaylimit;
    'runinterval':       value => $::puppet::runinterval;
    'noop':              value => $::puppet::agent_noop;
    'usecacheonfailure': value => $::puppet::usecacheonfailure;
  }
  if !$::puppet::use_srv_records {
    puppet::config::agent {
      'server':            value => pick($::puppet::config::puppetmaster, $::fqdn);
    }
  }
  if $::puppet::configtimeout != undef {
    puppet::config::agent {
      'configtimeout':     value => $::puppet::configtimeout;
    }
  }
  if $::puppet::prerun_command {
    puppet::config::agent {
      'prerun_command':    value => $::puppet::prerun_command;
    }
  }
  if $::puppet::postrun_command {
    puppet::config::agent {
      'postrun_command':   value => $::puppet::postrun_command;
    }
  }

  # we need to store this in a variable, because older puppet doesn't
  # like resource{function(): ... }
  $additional_settings_keys = keys($::puppet::agent_additional_settings)
  puppet::config::additional_settings{ $additional_settings_keys:
    hash     => $::puppet::agent_additional_settings,
    resource => '::puppet::config::agent',
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
    if $::puppet::remove_lock {
      file {'/var/lib/puppet/state/agent_disabled.lock':
        ensure => absent,
      }
    }
  }
}
