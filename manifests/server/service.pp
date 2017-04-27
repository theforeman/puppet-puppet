# == Class: puppet::server::service
#
# Set up the puppet server as a service
#
# === Parameters:
#
# $app_root::      Rack application top-level directory
#
# $httpd_service:: Apache/httpd service name, used for ordering
#
# $puppetmaster::  Whether to start/stop the (Ruby) puppetmaster service
#
# $puppetserver::  Whether to start/stop the (JVM) puppetserver service
#
# $rack::          Whether the Puppet server is running under Apache with Rack and Passenger
#                  Does not manage the Apache service, only restarts and ordering.
#
class puppet::server::service(
  Optional[Stdlib::Absolutepath] $app_root = undef,
  String $httpd_service = 'httpd',
  Optional[Boolean] $puppetmaster = undef,
  Optional[Boolean] $puppetserver = undef,
  Optional[Boolean] $rack = undef,
) {
  if $puppetmaster and $puppetserver {
    fail('Both puppetmaster and puppetserver cannot be enabled simultaneously')
  }

  if $::osfamily == 'Debian' and (versioncmp($::puppetversion, '4.0') > 0) {
    $puppetmaster_service = 'puppet-master'
  } else {
    $puppetmaster_service = 'puppetmaster'
  }

  if $puppetmaster != undef {
    $pm_ensure = $puppetmaster ? {
      true  => 'running',
      false => 'stopped',
    }
    service { $puppetmaster_service:
      ensure => $pm_ensure,
      enable => $puppetmaster,
    }

    if $rack and !$puppetmaster {
      Service[$puppetmaster_service] -> Service[$httpd_service]
    }
  }

  if $puppetserver != undef {
    $ps_ensure = $puppetserver ? {
      true  => 'running',
      false => 'stopped',
    }
    service { 'puppetserver':
      ensure => $ps_ensure,
      enable => $puppetserver,
    }

    if $rack and !$puppetserver {
      Service['puppetserver'] -> Service[$httpd_service]
    }
  }

  if $rack {
    exec {'restart_puppetmaster':
      command     => "/bin/touch ${app_root}/tmp/restart.txt",
      refreshonly => true,
      cwd         => $app_root,
    }
  }
}
