class puppet::service {
  service {'puppet': require => Class['puppet::install'] }
}
