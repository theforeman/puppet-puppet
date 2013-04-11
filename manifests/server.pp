# == Class: puppet::server
#
# Sets up a puppet master.
#
# === Parameters:
#
# $passenger::              If set to true, we will configure apache with
#                           passenger. If set to false, we will enable the
#                           default puppetmaster service unless
#                           service_fallback is set to false. See 'Advanced
#                           parameters for more information.
#                           Defaults to 'true;.
#
# TODO: Add more documentation
#
# === Advanced parameters:
#
# $httpd_service::          Apache/httpd service name to notify on configuration
#                           changes. Defaults to 'httpd' based on the default
#                           apache module included with foreman-installer.
#
# $service_fallback::       If passenger is not used, do we want to fallback
#                           to using the puppetmaster service? Set to false
#                           if you disabled passenger and you do NOT want to
#                           use the puppetmaster service. Defaults to true.
class puppet::server (
  ## These are inherited from the puppet class
  $dir                 = $puppet::dir,
  $port                = $puppet::port,
  $agent_template      = $puppet::agent_template,
  $version             = $puppet::version,

  ## These are only for the server.
  $user                = $puppet::params::user,
  $group               = $puppet::params::group,
  $vardir              = $puppet::params::vardir,
  $ca                  = $puppet::params::ca,
  $ca_server           = $puppet::params::ca_server,
  $passenger           = $puppet::params::passenger,
  $service_fallback    = $puppet::params::service_fallback,
  $httpd_service       = $puppet::params::httpd_service,
  $external_nodes      = $puppet::params::external_nodes,
  $environments        = $puppet::params::environments,
  $modules_path        = $puppet::params::modules_path,
  $manifest_path       = $puppet::params::manifest_path,
  $common_modules_path = $puppet::params::common_modules_path,
  $foreman_url         = $foreman::params::foreman_url,
  $facts               = $foreman::params::facts,
  $storeconfigs        = $foreman::params::storeconfigs,
  $storeconfigs_backend = $foreman::params::storeconfigs_backend,
  $puppet_home         = $foreman::params::puppet_home,
  $puppet_basedir      = $foreman::params::puppet_basedir,
  $git_repo            = $puppet::params::git_repo,
  $git_repo_path       = $puppet::params::git_repo_path,
  $envs_dir            = $puppet::params::envs_dir,
  $app_root            = $puppet::params::app_root,
  $ssl_dir             = $puppet::params::ssl_dir,
  $master_package      = $puppet::params::master_package,
  $post_hook_content   = $puppet::params::post_hook_content,
  $post_hook_name      = $puppet::params::post_hook_name,
  $master_template     = $puppet::params::master_template
) inherits puppet {

  if $passenger or ($service_fallback == false) {
    $use_service = false
  } else {
    $use_service = true
  }

  if $ca {
    $ssl_ca_cert   = "${ssl_dir}/ca/ca_crt.pem"
    $ssl_ca_crl    = "${ssl_dir}/ca/ca_crl.pem"
    $ssl_chain     = "${ssl_dir}/ca/ca_crt.pem"
  } else {
    $ssl_ca_cert = "${ssl_dir}/certs/ca.pem"
  }

  $ssl_cert      = "${ssl_dir}/certs/${::fqdn}.pem"
  $ssl_cert_key  = "${ssl_dir}/private_keys/${::fqdn}.pem"

  class { 'puppet::server::install': }~>
  class { 'puppet::server::config':  }~>
  class { 'puppet::server::service': }

}
