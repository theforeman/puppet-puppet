# Set up the puppet client as a cronjob
class puppet::cron inherits puppet::service {
  Service['puppet'] {
    enable => false,
    ensure => stopped,
  }

  $command = $puppet::cron_cmd ? {
    undef   => "/usr/bin/env puppet agent --config ${puppet::dir}/puppet.conf --onetime --no-daemonize",
    default => $puppet::cron_cmd,
  }

  $times = ip_to_cron($puppet::runinterval)

  cron { 'puppet':
    command => $command,
    user    => root,
    hour    => $times[0],
    minute  => $times[1],
  }

}
