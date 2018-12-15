class puppet::agent::service::systemd (
  Boolean $enabled = false,
) {
  unless 'systemd.timer' in $::puppet::unavailable_runmodes {
    exec { 'systemctl-daemon-reload-puppet':
      refreshonly => true,
      path        => $::path,
      command     => 'systemctl daemon-reload',
    }

    if $enabled {
      # Use the same times as for cron
      $times = extlib::ip_to_cron($::puppet::runinterval)

      $command = $::puppet::systemd_cmd ? {
        undef   => "${::puppet::puppet_cmd} agent --config ${::puppet::dir}/puppet.conf --onetime --no-daemonize --detailed-exitcode --no-usecacheonfailure",
        default => $::puppet::systemd_cmd,
      }

      $randomizeddelaysec = $::puppet::systemd_randomizeddelaysec

      file { "/etc/systemd/system/${::puppet::systemd_unit_name}.timer":
        content => template('puppet/agent/systemd.puppet-run.timer.erb'),
        notify  => [
          Exec['systemctl-daemon-reload-puppet'],
          Service['puppet-run.timer'],
        ],
      }

      file { "/etc/systemd/system/${::puppet::systemd_unit_name}.service":
        content => template('puppet/agent/systemd.puppet-run.service.erb'),
        notify  => Exec['systemctl-daemon-reload-puppet'],
      }

      service { 'puppet-run.timer':
        ensure   => running,
        provider => 'systemd',
        name     => "${::puppet::systemd_unit_name}.timer",
        enable   => true,
        require  => Exec['systemctl-daemon-reload-puppet'],
      }
    } else {
      # Reverse order - stop, delete files, exec
      service { 'puppet-run.timer':
        ensure   => stopped,
        provider => 'systemd',
        name     => "${::puppet::systemd_unit_name}.timer",
        enable   => false,
        before   => [
          File["/etc/systemd/system/${::puppet::systemd_unit_name}.timer"],
          File["/etc/systemd/system/${::puppet::systemd_unit_name}.service"],
        ],
      }

      file { "/etc/systemd/system/${::puppet::systemd_unit_name}.timer":
        ensure => absent,
        notify => Exec['systemctl-daemon-reload-puppet'],
      }

      file { "/etc/systemd/system/${::puppet::systemd_unit_name}.service":
        ensure => absent,
        notify => Exec['systemctl-daemon-reload-puppet'],
      }
    }
  }
}
