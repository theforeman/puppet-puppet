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
  $puppetmaster = true,
  $puppetserver = false,
) {
  validate_bool($puppetmaster, $puppetserver)

  if $puppetmaster and $puppetserver {
    fail('Both puppetmaster and puppetserver cannot be enabled simultaneously')
  }

  $pm_ensure = $puppetmaster ? {
    true  => 'running',
    false => 'stopped',
  }
  service { 'puppetmaster':
    ensure => $pm_ensure,
    enable => $puppetmaster,
  }

  $ps_ensure = $puppetserver ? {
    true  => 'running',
    false => 'stopped',
  }
  service { 'puppetserver':
    ensure => $ps_ensure,
    enable => $puppetserver,
  }

}
