class puppet::agent::service::cron (
  $enabled = false,
) {

  case $enabled {
    true: {
      $command = $puppet::cron_cmd ? {
        undef   => "/usr/bin/env puppet agent --config ${puppet::dir}/puppet.conf --onetime --no-daemonize",
        default => $puppet::cron_cmd,
      }

      if $::osfamily == 'windows' {
        fail("Currently we don't support setting cron on windows.")
      } else {
        $times = ip_to_cron($puppet::runinterval)
        cron { 'puppet':
          command => $command,
          user    => root,
          hour    => $times[0],
          minute  => $times[1],
        }
      }
    }
    false: {
      if $::osfamily != 'windows' {
        cron { 'puppet':
          ensure => absent,
        }
      }
    }
  }
}
