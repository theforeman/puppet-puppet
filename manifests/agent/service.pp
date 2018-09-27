# Set up the puppet client as a service
class puppet::agent::service {

  case $::puppet::runmode {
    'service': {
      $service_enabled = true
      $cron_enabled = false
      $systemd_enabled = false
    }
    'cron': {
      $service_enabled = false
      $cron_enabled = true
      $systemd_enabled = false
    }
    'systemd.timer', 'systemd': {
      $service_enabled = false
      $cron_enabled = false
      $systemd_enabled = true
    }
    'none': {
      $service_enabled = false
      $cron_enabled = false
      $systemd_enabled = false
    }
    default: {
      fail("Runmode of ${puppet::runmode} not supported by puppet::agent::config!")
    }
  }

  if $::puppet::runmode in $::puppet::unavailable_runmodes {
    fail("Runmode of ${puppet::runmode} not supported on ${::kernel} operating systems!")
  }

  # Ensure the service is started after registering the Foreman proxy
  # Relationship is duplicated there as defined() is parse-order dependent
  if defined(Foreman_smartproxy) {
    Foreman_smartproxy <| |> -> Class['puppet::agent::service']
  }

  class { 'puppet::agent::service::daemon':
    enabled => $service_enabled,
  }
  contain puppet::agent::service::daemon

  class { 'puppet::agent::service::systemd':
    enabled => $systemd_enabled,
  }
  contain puppet::agent::service::systemd

  class { 'puppet::agent::service::cron':
    enabled => $cron_enabled,
  }
  contain puppet::agent::service::cron
}
