# == Class: puppet::server::service
#
# Set up the puppet server as a service
#
# === Parameters:
#
# $puppetmaster::  Whether to start/stop the (Ruby) puppetmaster service
#                  type:boolean
#
# $puppetserver::  Whether to start/stop the (JVM) puppetserver service
#                  type:boolean
#
class puppet::server::service(
  $puppetmaster = undef,
  $puppetserver = undef,
) {
  if $puppetmaster and $puppetserver {
    fail('Both puppetmaster and puppetserver cannot be enabled simultaneously')
  }

  if $puppetmaster != undef {
    $pm_ensure = $puppetmaster ? {
      true  => 'running',
      false => 'stopped',
    }
    service { 'puppetmaster':
      ensure => $pm_ensure,
      enable => $puppetmaster,
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
  }

}
