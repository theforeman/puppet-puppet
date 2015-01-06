# Set up the puppet client as a service
class puppet::agent::service {

  case $::puppet::runmode {
    'service': {
      service {'puppet':
        ensure    => running,
        name      => $puppet::params::service_name,
        hasstatus => true,
        enable    => true,
      }

      if $::osfamily != 'windows' {
        cron { 'puppet':
          ensure => absent,
        }
      }
    }
    'cron': {
      service {'puppet':
        ensure    => stopped,
        name      => $puppet::params::service_name,
        hasstatus => true,
        enable    => false,
      }

      $command = $puppet::cron_cmd ? {
        undef   => "/usr/bin/env puppet agent --config ${puppet::dir}/puppet.conf --onetime --no-daemonize",
        default => $puppet::cron_cmd,
      }

      if $::osfamily == 'windows' {
        fail("Currently we don't support setting cron on windows.")
      } else {
        $times = ip_to_cron($puppet::runinterval)
        cron { 'puppet':
          command => $command,
          user    => root,
          hour    => $times[0],
          minute  => $times[1],
        }
      }
    }
    'none': {
      service { 'puppet':
        ensure    => stopped,
        name      => $puppet::params::service_name,
        hasstatus => true,
        enable    => false,
      }

      if $::osfamily != 'windows' {
        cron { 'puppet':
          ensure => absent,
        }
      }
    }
    default: {
      fail("Runmode of ${puppet::runmode} not supported by puppet::agent::config!")
    }
  }
}
