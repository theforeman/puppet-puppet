# Set up running the agent via a systemd timer
#
# @summary Configures Puppet agent to run via systemd timer
#
# This class sets up a systemd timer and service to run the Puppet agent
# at regular intervals instead of running as a daemon service or cron job.
# This provides better integration with systemd logging and service management.
#
# @param enabled
#   Whether to enable the systemd timer for puppet agent runs.
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
# @param timezone
#   The timezone to use for the systemd timer. If not specified,
#   the system timezone will be used.
#
# @api private
class puppet::agent::service::systemd (
  Boolean                 $enabled                             = false,
  Optional[Integer[0,23]] $hour                                = undef,
  Variant[Integer[0,59], Array[Integer[0,59]], Undef] $minute  = undef,
  Optional[String[1]] $timezone                                = undef,
) {
  unless $puppet::runmode == 'unmanaged' or 'systemd.timer' in $puppet::unavailable_runmodes {
    # Use the same times as for cron
    $times = extlib::ip_to_cron($puppet::runinterval)

    # But only if they are not explicitly specified
    $_hour = pick($hour, $times[0])
    $_minute = pick($minute, $times[1])

    $command = pick($puppet::systemd_cmd, "${puppet::puppet_cmd} agent --config ${puppet::dir}/puppet.conf --onetime --no-daemonize --detailed-exitcode --no-usecacheonfailure")
    $randomizeddelaysec = $puppet::systemd_randomizeddelaysec

    systemd::timer { "${puppet::systemd_unit_name}.timer":
      ensure          => bool2str($enabled, 'present', 'absent'),
      active          => $enabled,
      enable          => $enabled,
      timer_content   => template('puppet/agent/systemd.puppet-run.timer.erb'),
      service_content => template('puppet/agent/systemd.puppet-run.service.erb'),
    }
  }
}
