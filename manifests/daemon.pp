class puppet::cron inherits puppet::service {
  Service['puppet'] {
    enable => true,
    ensure => running,
  }
}
