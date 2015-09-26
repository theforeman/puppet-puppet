class puppet::agent::service::systemd (
  $enabled = false,
) {
  case $enabled {
    true: {
      # Use the same times as for cron
      $times = ip_to_cron($puppet::runinterval)

      $command = $puppet::cron_cmd ? {
        undef   => "/usr/bin/env puppet agent --config ${puppet::dir}/puppet.conf --onetime --no-daemonize",
        default => $puppet::cron_cmd,
      }

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
    false: {
      # Reverse order - stop, delete files, exec
      service { 'puppetcron.timer':
        provider => 'systemd',
        ensure   => stopped,
        enable   => false,
        before   => [
          File['/etc/systemd/system/puppetcron.timer'],
          File['/etc/systemd/system/puppetcron.service'],
        ],
      }

      file { '/etc/systemd/system/puppetcron.timer':
        ensure => absent,
        notify => Exec['systemctl-daemon-reload'],
      }

      file { '/etc/systemd/system/puppetcron.service':
        ensure => absent,
        notify  => Exec['systemctl-daemon-reload'],
      }

      exec { 'systemctl-daemon-reload':
        refreshonly => true,
        path        => $::path,
        command     => 'systemctl daemon-reload',
      }
    }
  }
}
