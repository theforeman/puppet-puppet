# Set up running the agent via cron
# @api private
class puppet::agent::service::cron (
  Boolean                 $enabled = false,
  Optional[Integer[0,23]] $hour    = undef,
  Optional[Integer[0,59]] $minute  = undef,
) {
  unless $::puppet::runmode == 'unmanaged' or 'cron' in $::puppet::unavailable_runmodes {
    if $enabled {
      $command = pick($::puppet::cron_cmd, "${::puppet::puppet_cmd} agent --config ${::puppet::dir}/puppet.conf --onetime --no-daemonize")
      $times = extlib::ip_to_cron($::puppet::runinterval)

      $_hour = pick($hour, $times[0])
      $_minute = pick($minute, $times[1])

      cron { 'puppet':
        command => $command,
        user    => root,
        hour    => $_hour,
        minute  => $_minute,
      }
    } else{
      cron { 'puppet':
        ensure => absent,
      }
    }
  }
}
