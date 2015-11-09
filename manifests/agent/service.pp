# Set up the puppet client as a service
class puppet::agent::service {

  if !($::puppet::runmode in ['systemd', 'cron', 'service', 'none']) {
    fail("Runmode of ${puppet::runmode} not supported by puppet::agent::config!")
  }

  if $::puppet::runmode == 'service' {
      service {'puppet':
        ensure     => running,
        name       => $puppet::service_name,
        hasstatus  => true,
        hasrestart => $puppet::agent_restart_command != undef,
        enable     => true,
        restart    => $puppet::agent_restart_command,
      }
  } else {
    service { 'puppet':
      ensure    => stopped,
      name      => $puppet::service_name,
      hasstatus => true,
      enable    => false,
    }
  }

  if $::puppet::runmode == 'systemd' {
    $command = $puppet::systemd_cmd ? {
      undef   => "/usr/bin/env puppet agent --config ${puppet::dir}/puppet.conf --onetime --no-daemonize --detailed-exitcodes --no-usecacheonfailure",
      default => $puppet::systemd_cmd,
    }

    if $::osfamily == 'windows' {
      fail("We don't support systemd on Windows.")
    } else {
      $times = ip_to_cron($puppet::runinterval)
      file{
        "/etc/systemd/system/${puppet::systemd_service_name}.timer":
          ensure  => file,
          content => template('puppet/systemd.timer.erb'),
          notify  => [
            Exec['systemctl-daemon-reload-puppet'],
            Service['puppet-run.timer'],
          ],
      }
      file{
        "/etc/systemd/system/${puppet::systemd_service_name}.service":
          ensure  => file,
          content => template('puppet/systemd.service.erb'),
          notify  => [
            Exec['systemctl-daemon-reload-puppet']
          ],
      }
      exec {
        'systemctl-daemon-reload-puppet':
          command     => '/bin/systemctl daemon-reload',
          refreshonly => true,
      }
      service {'puppet-run.timer':
        ensure    => running,
        name      => "${puppet::systemd_service_name}.timer",
        hasstatus => true,
        enable    => true,
        require   => Exec['systemctl-daemon-reload-puppet'],
      }
    }
  }
  else {
    if $::osfamily != 'windows' {
      file{
        "/etc/systemd/system/${puppet::systemd_service_name}.timer":
          ensure => absent,
          notify => [
            Exec['systemctl-daemon-reload-puppet'],
            Service['puppet-run.timer'],
          ],
      }
      file{
        "/etc/systemd/system/${puppet::systemd_service_name}.service":
          ensure => absent,
          notify => [
            Exec['systemctl-daemon-reload-puppet']
          ],
      }
      exec {
        'systemctl-daemon-reload-puppet':
          command     => '/bin/systemctl daemon-reload',
          refreshonly => true,
      }
      service {'puppet-run.timer':
        ensure    => stopped,
        name      => "${puppet::systemd_service_name}.timer",
        hasstatus => true,
        enable    => false,
        require   => Exec['systemctl-daemon-reload-puppet'],
      }
    }
  }


  if $::puppet::runmode == 'cron' {
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
  } else {
    if $::osfamily != 'windows' {
      cron { 'puppet':
        ensure => absent,
      }
    }
  }
}
