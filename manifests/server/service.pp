class puppet::server::service {

  $ensured = $puppet::server::passenger ? { false => 'running', default => 'stopped', }
  $enabled = $puppet::server::passenger ? { false => true,      default => false, }

  service { 'puppetmaster':
    ensure => $ensured,
    enable => $enabled,
  }

}
