# Puppet agent configuration
# @api private
class puppet::agent::config inherits puppet::config {
  puppet::config::agent {
    'classfile':         value => $puppet::classfile;
    'localconfig':       value => $puppet::localconfig;
    'default_schedules': value => $puppet::agent_default_schedules;
    'report':            value => $puppet::report;
    'masterport':        value => $puppet::port;
    'environment':       value => $puppet::environment;
    'splay':             value => $puppet::splay;
    'splaylimit':        value => $puppet::splaylimit;
    'runinterval':       value => $puppet::runinterval;
    'noop':              value => $puppet::agent_noop;
    'usecacheonfailure': value => $puppet::usecacheonfailure;
  }
  if $puppet::http_connect_timeout != undef {
    puppet::config::agent {
      'http_connect_timeout': value => $puppet::http_connect_timeout;
    }
  }
  if $puppet::http_read_timeout != undef {
    puppet::config::agent {
      'http_read_timeout': value => $puppet::http_read_timeout;
    }
  }
  if $puppet::prerun_command {
    puppet::config::agent {
      'prerun_command':  value => $puppet::prerun_command;
    }
  }
  if $puppet::postrun_command {
    puppet::config::agent {
      'postrun_command': value => $puppet::postrun_command;
    }
  }

  $puppet::agent_additional_settings.each |$key,$value| {
    puppet::config::agent { $key: value => $value }
  }
}
