# == Class: puppet
#
# This class installs and configures the puppet agent.
#
# === Parameters:
#
# $dir::              Override the puppet directory.
#                     Defaults to '/etc/puppet'.
#
# $ca_server::        Use a different ca server. Should be either a string
#                     with the location of the ca_server or 'false'.
#                     Defaults to 'false;.
#
# $port::             Override the port of the master we connect to.
#                     Defaults to '8140'.
#
# $listen::           Should the puppet agent listen for connections.
#                     Defaults to 'false'.
#
# $pluginsync::       Enable pluginsync.
#                     Defaults to 'true'.
#
# $splay::            Switch to enable a random amount of time to sleep before
#                     each run.
#                     Defaults to 'false'.
#
# $runinterval::      Set up the interval to run the puppet agent.
#                     Defaults to '1800' (seconds).
#
# $runmode::          Select the mode to setup the puppet agent. Can be either
#                     'cron' or 'service'.
#                     Defaults to 'service'.
#
# $noop::             Run the client in noop mode.
#                     Defaults to 'false'.
#
# $agent_template::   Use a custom template for the agent puppet configuration.
#
# $auth_template::    Use a custom template for the auth configuration.
#
# $nsauth_template::  Use a custom template for the nsauth configuration.
#
# $version::          Specify a specific version of a package to install.
#                     The version should be the exact match for your distro.
#                     You can also use certain values like 'latest'.
#                     Defaults to 'present'.
#
# === Usage:
#
# * Simple usage:
#
#     include puppet
#
# * Advanced usage:
#
#   class {'puppet':
#     noop    => true,
#     version => '2.7.20-1',
#   }
#
#
class puppet (
  $dir                 = $puppet::params::dir,
  $ca_server           = $puppet::params::ca_server,
  $port                = $puppet::params::port,
  $listen              = $puppet::params::listen,
  $pluginsync          = $puppet::params::pluginsync,
  $splay               = $puppet::params::splay,
  $runinterval         = $puppet::params::runinterval,
  $runmode             = $puppet::params::runmode,
  $noop                = $puppet::params::noop,
  $agent_template      = $puppet::params::agent_template,
  $auth_template       = $puppet::params::auth_template,
  $nsauth_template     = $puppet::params::nsauth_template,
  $version             = $puppet::params::version
) inherits puppet::params {
  class { 'puppet::install': }~>
  class { 'puppet::config': }
}
