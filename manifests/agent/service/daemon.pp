# Set up running the agent as a daemon
# @api private
class puppet::agent::service::daemon (
  Boolean $enabled = false,
) {
  unless $puppet::runmode == 'unmanaged' or 'service' in $puppet::unavailable_runmodes {
    if $enabled {
      service {'puppet':
        ensure     => running,
        name       => $puppet::service_name,
        hasstatus  => true,
        hasrestart => $puppet::agent_restart_command != undef,
        enable     => true,
        restart    => $puppet::agent_restart_command,
      }
    } else {
      service {'puppet':
        ensure    => stopped,
        name      => $puppet::service_name,
        hasstatus => true,
        enable    => false,
      }
    }
  }
}
