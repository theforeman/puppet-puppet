# Set up running the agent as a daemon
#
# @summary Configures Puppet agent to run as a daemon service
#
# This class manages the puppet agent service, ensuring it runs as a 
# background daemon process that continuously checks for configuration
# changes at the specified runinterval.
#
# @param enabled
#   Whether to enable and start the puppet agent daemon service.
#   When true, the service will be running and enabled. When false,
#   the service will be stopped and disabled.
#
# @api private
class puppet::agent::service::daemon (
  Boolean $enabled = false,
) {
  unless $puppet::runmode == 'unmanaged' or 'service' in $puppet::unavailable_runmodes {
    if $enabled {
      service { 'puppet':
        ensure     => running,
        name       => $puppet::service_name,
        hasstatus  => true,
        hasrestart => $puppet::agent_restart_command != undef,
        enable     => true,
        restart    => $puppet::agent_restart_command,
      }
    } else {
      service { 'puppet':
        ensure    => stopped,
        name      => $puppet::service_name,
        hasstatus => true,
        enable    => false,
      }
    }
  }
}
