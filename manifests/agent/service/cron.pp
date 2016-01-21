class puppet::agent::service::cron (
  $enabled = false,
) {
  if ! ('cron' in $::puppet::unavailable_runmodes) {
    case $enabled {
      true: {
        $command = $::puppet::cron_cmd ? {
          undef   => "${::puppet::puppet_cmd} agent --config ${::puppet::dir}/puppet.conf --onetime --no-daemonize",
          default => $::puppet::cron_cmd,
        }

        $times = ip_to_cron($::puppet::runinterval)
        cron { 'puppet':
          command => $command,
          user    => root,
          hour    => $times[0],
          minute  => $times[1],
        }
      }
      false: {
        cron { 'puppet':
          ensure => absent,
        }
      }
    }
  }
}
