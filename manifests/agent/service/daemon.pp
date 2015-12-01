class puppet::agent::service::daemon (
  $enabled = false,
) {
  if ! ('service' in $::puppet::unavailable_runmodes) {
    case $enabled {
      true: {
        service {'puppet':
          ensure     => running,
          name       => $puppet::service_name,
          hasstatus  => true,
          hasrestart => $puppet::agent_restart_command != undef,
          enable     => true,
          restart    => $puppet::agent_restart_command,
        }
      }
      false: {
        service {'puppet':
          ensure    => stopped,
          name      => $puppet::service_name,
          hasstatus => true,
          enable    => false,
        }
      }
      default: { fail('puppet::agent::service::daemon::enabled should be true or false') }
    }
  }
}
