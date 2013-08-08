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
#                           type:boolean
#
# $user::                   Puppet user
#
# $group::                  Puppet group
#
# $dir::                    Puppet configuration directory
#
# $vardir::                 Puppet data directory
#
# $ca::                     Provide puppet CA
#                           type:boolean
#
# $port::                   Puppet master port
#                           type:integer
#
# $external_nodes::         External nodes classifier executable
#
# $environments::           Environments to setup (creates directories)
#                           type:array
#
# $manifest_path::          Path to puppet site.pp manifest
#
# $common_modules_path::    Common modules paths
#                           type:array
#
# $foreman_url::            Foreman URL
#
# $facts::                  Should foreman receive facts from puppet
#                           type:boolean
#
# $puppet_basedir::         Where is the puppet code base located
#
# $puppet_home::            Puppet var directory
#
# $storeconfigs_backend::   Do you use storeconfigs? (note: not required)
#                           false if you don't, "active_record" for 2.X style db, "puppetdb" for puppetdb
#
# $git_repo::               Use git repository as a source of modules
#                           type:boolean
#
# $git_repo_path::          Git repository path
#
# $envs_dir::               Directory that holds puppet environments
#
# $app_root::               Directory where the application lives
#
# $ssl_dir::                SSL directory
#
# $master_package::         Custom package name for puppet master
#
# $post_hook_content::      Which template to use for git post hook
#
# $post_hook_name::         Name of a git hook
#
# $agent_template::         Which template should be used for agent configuration
#
# $master_template::        Which template should be used for master configuration
#
# $version::                Puppet master version
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
#                           type:boolean
#
# $passenger_max_pool::     The PassengerMaxPoolSize parameter. If your host is
#                           low on memory, it may be a good thing to lower
#                           this. Defaults to 12.
#                           type:integer
#
# $config_version::         How to determine the configuration version. When
#                           using git_repo, by default a git describe approach
#                           will be installed.
#
class puppet::server (
  ## These are inherited from the puppet class
  $dir                  = $puppet::dir,
  $port                 = $puppet::port,
  $agent_template       = $puppet::agent_template,
  $version              = $puppet::version,

  ## These are only for the server
  $user                 = $puppet::params::user,
  $group                = $puppet::params::group,
  $vardir               = $puppet::params::vardir,
  $ca                   = $puppet::params::ca,
  $passenger            = $puppet::params::passenger,
  $service_fallback     = $puppet::params::service_fallback,
  $passenger_max_pool   = $puppet::params::passenger_max_pool,
  $httpd_service        = $puppet::params::httpd_service,
  $external_nodes       = $puppet::params::external_nodes,
  $config_version       = $puppet::params::config_version,
  $environments         = $puppet::params::environments,
  $manifest_path        = $puppet::params::manifest_path,
  $common_modules_path  = $puppet::params::common_modules_path,
  $reports              = $puppet::params::reports,
  $foreman_url          = $foreman::params::foreman_url,
  $facts                = $foreman::params::facts,
  $storeconfigs_backend = $puppet::params::storeconfigs_backend,
  $puppet_home          = $foreman::params::puppet_home,
  $puppet_basedir       = $foreman::params::puppet_basedir,
  $git_repo             = $puppet::params::git_repo,
  $git_repo_path        = $puppet::params::git_repo_path,
  $envs_dir             = $puppet::params::envs_dir,
  $app_root             = $puppet::params::app_root,
  $ssl_dir              = $puppet::params::ssl_dir,
  $master_package       = $puppet::params::master_package,
  $post_hook_content    = $puppet::params::post_hook_content,
  $post_hook_name       = $puppet::params::post_hook_name,
  $master_template      = $puppet::params::master_template
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

  if $config_version == undef {
    if $git_repo {
      $config_version_cmd = "git --git-dir ${envs_dir}/\$environment/.git describe --all --long"
    } else {
      $config_version_cmd = ''
    }
  } else {
    $config_version_cmd = $config_version
  }

  class { 'puppet::server::install': }~>
  class { 'puppet::server::config':  }~>
  class { 'puppet::server::service': }

}
