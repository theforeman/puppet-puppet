# Puppet agent configuration
# @api private
class puppet::agent::config inherits puppet::config {
  puppet::config::agent{
    'classfile':         value => $::puppet::classfile;
    'localconfig':       value => '$vardir/localconfig';
    'default_schedules': value => false;
    'report':            value => $::puppet::report;
    'masterport':        value => $::puppet::port;
    'environment':       value => $::puppet::environment;
    'listen':            value => $::puppet::listen;
    'splay':             value => $::puppet::splay;
    'splaylimit':        value => $::puppet::splaylimit;
    'runinterval':       value => $::puppet::runinterval;
    'noop':              value => $::puppet::agent_noop;
    'usecacheonfailure': value => $::puppet::usecacheonfailure;
  }
  if $::puppet::http_connect_timeout != undef {
    puppet::config::agent {
      'http_connect_timeout': value => $::puppet::http_connect_timeout;
    }
  }
  if $::puppet::http_read_timeout != undef {
    puppet::config::agent {
      'http_read_timeout': value => $::puppet::http_read_timeout;
    }
  }
  if $::puppet::prerun_command {
    puppet::config::agent {
      'prerun_command':  value => $::puppet::prerun_command;
    }
  }
  if $::puppet::postrun_command {
    puppet::config::agent {
      'postrun_command': value => $::puppet::postrun_command;
    }
  }

  unless $::puppet::pluginsync {
    if versioncmp($facts['puppetserver'], '6.0.0') >= 0 {
      fail('pluginsync is no longer a setting in Puppet 6')
    } else {
      puppet::config::agent { 'pluginsync':
        value => $::puppet::pluginsync,
      }
    }
  }

  $::puppet::agent_additional_settings.each |$key,$value| {
    puppet::config::agent { $key: value => $value }
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
