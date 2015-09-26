# Set up the puppet client as a service
class puppet::agent::service {

  case $::puppet::runmode {
    'service': {
      class { 'puppet::agent::service::daemon':  enabled => true  }
      class { 'puppet::agent::service::cron':    enabled => false }
      class { 'puppet::agent::service::systemd': enabled => false }
    }
    'cron': {
      class { 'puppet::agent::service::daemon':  enabled => false }
      class { 'puppet::agent::service::cron':    enabled => true  }
      class { 'puppet::agent::service::systemd': enabled => false }
    }
    'systemd.timer': {
      class { 'puppet::agent::service::daemon':  enabled => false }
      class { 'puppet::agent::service::cron':    enabled => false }
      class { 'puppet::agent::service::systemd': enabled => true  }
    }
    'none': {
      class { 'puppet::agent::service::daemon':  enabled => false }
      class { 'puppet::agent::service::cron':    enabled => false }
      class { 'puppet::agent::service::systemd': enabled => false }
    }
    default: {
      fail("Runmode of ${puppet::runmode} not supported by puppet::agent::config!")
    }
  }
}
