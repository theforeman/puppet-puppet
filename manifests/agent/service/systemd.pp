# Set up running the agent via a systemd timer
# @api private
class puppet::agent::service::systemd (
  Boolean                 $enabled                             = false,
  Optional[Integer[0,23]] $hour                                = undef,
  Variant[Integer[0,59], Array[Integer[0,59]], Undef] $minute  = undef,
  Optional[String] $timezone                                   = undef,
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
