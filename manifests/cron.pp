class puppet::cron inherits puppet::service {
  Service['puppet'] {
    enable => false,
    ensure => stopped,
  }

  cron {'puppet':
    command => "sleep $((RANDOM%59)) && /usr/sbin/puppet agent --config ${puppet::params::dir}/puppet.conf --onetime --no-daemonize",
    user    => root,
    minute  => ip_to_cron($puppet::params::cron_interval, $puppet::params::cron_range),
  }
}
