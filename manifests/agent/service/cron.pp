# Set up running the agent via cron
# @api private
class puppet::agent::service::cron (
  Boolean $enabled = false,
) {
  unless $::puppet::runmode == 'unmanaged' or 'cron' in $::puppet::unavailable_runmodes {
    if $enabled {
      $command = pick($::puppet::cron_cmd, "${::puppet::puppet_cmd} agent --config ${::puppet::dir}/puppet.conf --onetime --no-daemonize")
      $times = extlib::ip_to_cron($::puppet::runinterval)
      cron { 'puppet':
        command => $command,
        user    => root,
        hour    => $times[0],
        minute  => $times[1],
      }
    } else{
      cron { 'puppet':
        ensure => absent,
      }
    }
  }
}
