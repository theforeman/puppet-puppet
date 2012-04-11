class puppet::daemon inherits puppet::service {
  Service['puppet'] {
    enable => true,
    ensure => running,
  }

  cron { 'puppet': ensure => absent }

}
