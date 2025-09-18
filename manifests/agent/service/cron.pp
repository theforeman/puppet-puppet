# Set up running the agent via cron
#
# @summary Configures Puppet agent to run via cron
#
# This class sets up a cron job to run the Puppet agent at regular intervals
# instead of running as a daemon service.
#
# @param enabled
#   Whether to enable the cron-based puppet agent runs.
#
# @param hour
#   The hour(s) when puppet should run (0-23). If not specified, 
#   it will be calculated based on the runinterval.
#
# @param minute
#   The minute(s) when puppet should run (0-59). Can be an integer,
#   array of integers, or undef. If not specified, it will be calculated
#   based on the runinterval.
#
# @api private
class puppet::agent::service::cron (
  Boolean                 $enabled                             = false,
  Optional[Integer[0,23]] $hour                                = undef,
  Variant[Integer[0,59], Array[Integer[0,59]], Undef] $minute  = undef,
) {
  unless $puppet::runmode == 'unmanaged' or 'cron' in $puppet::unavailable_runmodes {
    if $enabled {
      $command = pick($puppet::cron_cmd, "${puppet::puppet_cmd} agent --config ${puppet::dir}/puppet.conf --onetime --no-daemonize")
      $times = extlib::ip_to_cron($puppet::runinterval)

      $_hour = pick($hour, $times[0])
      $_minute = pick($minute, $times[1])

      cron { 'puppet':
        command => $command,
        user    => root,
        hour    => $_hour,
        minute  => $_minute,
      }
    } else {
      cron { 'puppet':
        ensure => absent,
      }
    }
  }
}
