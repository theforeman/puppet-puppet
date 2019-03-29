# Set up the puppet agent as a service
# @api private
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
    'none', 'unmanaged': {
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

  class { 'puppet::agent::service::daemon':
    enabled => $service_enabled,
  }
  contain puppet::agent::service::daemon

  class { 'puppet::agent::service::systemd':
    enabled => $systemd_enabled,
    hour    => $::puppet::run_hour,
    minute  => $::puppet::run_minute,
  }
  contain puppet::agent::service::systemd

  class { 'puppet::agent::service::cron':
    enabled => $cron_enabled,
    hour    => $::puppet::run_hour,
    minute  => $::puppet::run_minute,
  }
  contain puppet::agent::service::cron
}
