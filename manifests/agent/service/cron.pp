# Set up running the agent via cron
# @api private
class puppet::agent::service::cron (
  Boolean                 $enabled                             = false,
  Optional[Integer[0,23]] $hour                                = undef,
  Variant[Integer[0,59], Array[Integer[0,59]], Undef] $minute  = undef,
) {
  unless $puppet::runmode == 'unmanaged' or 'cron' in $puppet::unavailable_runmodes {
    if $enabled {
      $command = pick($puppet::cron_cmd, "${puppet::puppet_cmd} agent --config ${puppet::dir}/puppet.conf --onetime --no-daemonize")
      $target = $puppet::cron_target
      $times = extlib::ip_to_cron($puppet::runinterval)

      $_hour = pick($hour, $times[0])
      $_minute = pick($minute, $times[1])

      cron { 'puppet':
        command => $command,
        user    => root,
        hour    => $_hour,
        minute  => $_minute,
        target  => $target,
      }
    } else {
      cron { 'puppet':
        ensure => absent,
      }
    }
  }
}
