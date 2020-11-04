$packages = $facts['os']['name'] ? {
  # iproute is needed for the ss command in testing and not included in the base container
  'Fedora' => ['cronie', 'iproute'],
  'Ubuntu' => ['cron'],
  default  => [],
}

package { $packages:
  ensure => installed,
}
