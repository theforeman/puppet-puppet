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

  cron { 'puppet':
    command => $command,
    user    => root,
    minute  => ip_to_cron($puppet::cron_interval, $puppet::cron_range),
  }

}
