# Set up the puppet server as a service
class puppet::server::service {

  if $::puppet::server::use_service {
    $ensured = 'running'
    $enabled = true
  } else {
    $ensured = 'stopped'
    $enabled = false
  }

  service { 'puppetmaster':
    ensure => $ensured,
    enable => $enabled,
  }

}
