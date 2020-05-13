$packages = $facts['os']['name'] ? {
  'Fedora' => ['cronie'],
  'Ubuntu' => ['cron'],
  default  => [],
}

package { $packages:
  ensure => installed,
}
