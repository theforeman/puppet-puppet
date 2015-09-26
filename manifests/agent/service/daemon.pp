class puppet::agent::service::daemon (
  $enabled = false,
) {
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
  }
}
