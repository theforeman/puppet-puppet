# The puppet module
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
