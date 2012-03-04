class puppet::cron inherits puppet::service {
  include puppet
  Service['puppet'] {
    enable => false,
    ensure => undef,
  }

  cron {'puppet':
    command => "/usr/sbin/puppetd --config ${puppet::params::dir}/puppet.conf -o",
    user    => root,
    minute  => ip_to_cron($puppet::params::cron_interval, $puppet::params::cron_range),
  }
}
