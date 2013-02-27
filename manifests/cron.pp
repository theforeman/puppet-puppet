# Set up the puppet client as a cronjob
class puppet::cron inherits puppet::service {
  Service['puppet'] {
    enable => false,
    ensure => stopped,
  }

  cron { 'puppet':
    command => "/usr/bin/env puppet agent --config ${puppet::dir}/puppet.conf --onetime --no-daemonize",
    user    => root,
    minute  => ip_to_cron($puppet::cron_interval, $puppet::cron_range),
  }

}
