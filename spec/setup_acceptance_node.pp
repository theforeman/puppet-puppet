if $facts['os']['name'] == 'Ubuntu' {
  package { 'cron':
    ensure => installed,
  }
}
