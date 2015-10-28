# Set up the puppet client as a service
class puppet::agent::service {

  case $::puppet::runmode {
    'service': {
      service {'puppet':
        ensure     => running,
        name       => $puppet::service_name,
        hasstatus  => true,
        hasrestart => $puppet::agent_restart_command != undef,
        enable     => true,
        restart    => $puppet::agent_restart_command,
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
        name      => $puppet::service_name,
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
    'systemd.timer': {
      # Use the same times as for cron
      $times = ip_to_cron($puppet::runinterval)

      file { '/etc/systemd/system/puppetcron.timer':
        content => template('puppet/agent/systemd.puppetcron.timer.erb'),
        notify  => Exec['systemctl-daemon-reload'],
      }

      file { '/etc/systemd/system/puppetcron.service':
        content => template('puppet/agent/systemd.puppetcron.service.erb'),
        notify  => Exec['systemctl-daemon-reload'],
      }

      exec { 'systemctl-daemon-reload':
        refreshonly => true,
        path        => $::path,
        command     => 'systemctl daemon-reload',
        subscribe   => [
          File['/etc/systemd/system/puppetcron.service'],
          File['/etc/systemd/system/puppetcron.timer'],
        ],
      }

      service { 'puppetcron.timer':
        provider  => 'systemd',
        ensure    => running,
        enable    => true,
        subscribe => [
          File['/etc/systemd/system/puppetcron.timer'],
          File['/etc/systemd/system/puppetcron.service'],
          Exec['systemctl-daemon-reload'],
        ],
      }

    }
    'none': {
      service { 'puppet':
        ensure    => stopped,
        name      => $puppet::service_name,
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
