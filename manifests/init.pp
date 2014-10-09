# == Class: puppet
#
# This class installs and configures the puppet agent.
#
# === Parameters:
#
# $version::                       Specify a specific version of a package to
#                                  install. The version should be the exact
#                                  match for your distro.
#                                  You can also use certain values like 'latest'.
#
# $user::                          Override the name of the puppet user.
#
# $group::                         Override the name of the puppet group.
#
# $dir::                           Override the puppet directory.
#
# $port::                          Override the port of the master we connect to.
#                                  type:integer
#
# $listen::                        Should the puppet agent listen for connections.
#                                  type:boolean
# $pluginsync::                    Enable pluginsync.
#                                  type:boolean
#
# $splay::                         Switch to enable a random amount of time
#                                  to sleep before each run.
#                                  type:boolean
#
# $splaylimit::                    The maximum time to delay before runs.
#                                  Defaults to being the same as the run interval.
#                                  This setting can be a time interval in seconds
#                                  (30 or 30s), minutes (30m), hours (6h), days (2d),
#                                  or years (5y).
#
# $runinterval::                   Set up the interval (in seconds) to run
#                                  the puppet agent.
#                                  type:integer
#
# $usecacheonfailure::             Switch to enable use of cached catalog on
#                                  failure of run.
#                                  type: boolean
#
# $runmode::                       Select the mode to setup the puppet agent.
#                                  Can be either 'cron', 'service', or 'none'.
#
# $cron_cmd::                      Specify command to launch when runmode is
#                                  set 'cron'.
#
# $show_diff::                     Show and report changed files with diff output
#
# $configtimeout::                 How long the client should wait for the
#                                  configuration to be retrieved before
#                                  considering it a failure.
#                                  type:integer
#
# $ca_server::                     Use a different ca server. Should be either
#                                  a string with the location of the ca_server
#                                  or 'false'.
#
# $dns_alt_names::                 Use additional DNS names when generating a
#                                  certificate.  Defaults to an empty Array.
#                                  type:array
#
# $classfile::                     The file in which puppet agent stores a list
#                                  of the classes associated with the retrieved
#                                  configuration.
#
# $hiera_config::                  The hiera configuration file.
#                                  Defaults to '$confdir/hiera.yaml'.
#                                  type:string
#
# $syslogfacility::                Facility name to use when logging to syslog
#
# $auth_template::                 Use a custom template for the auth
#                                  configuration.
#
# $nsauth_template::               Use a custom template for the nsauth configuration.
#
# $main_template::                 Use a custom template for the main puppet
#                                  configuration.
#
# $use_srv_records::               Whether DNS SRV records will be used to resolve
#                                  the Puppet master
#                                  type:boolean
#
# $srv_domain::                    Search domain for SRV records
#
# $pluginsource::                  URL to retrieve Puppet plugins from during pluginsync
#
# == puppet::agent parameters
#
# $agent::                         Should a puppet agent be installed
#                                  type:boolean
#
# $agent_noop::                    Run the agent in noop mode.
#                                  type:boolean
#
# $agent_template::                Use a custom template for the agent puppet
#                                  configuration.
#
# $client_package::                Install a custom package to provide
#                                  the puppet client
#
# $puppetmaster::                  Hostname of your puppetmaster (server
#                                  directive in puppet.conf)
#
# == puppet::server parameters
#
# $server::                        Should a puppet master be installed as well as the client
#                                  type:boolean
#
# $server_user::                   Name of the puppetmaster user.
#
# $server_group::                  Name of the puppetmaster group.
#
# $server_dir::                    Puppet configuration directory
#
# $server_port::                   Puppet master port
#                                  type:integer
#
# $server_vardir::                 Puppet data directory.
#
# $server_ca::                     Provide puppet CA
#                                  type:boolean
#
# $server_reports::                List of report types to include on the puppetmaster
#
# $server_implementation::         Puppet master implementation, either "master" (traditional
#                                  Ruby) or "puppetserver" (JVM-based)
#
# $server_passenger::              If set to true, we will configure apache with
#                                  passenger. If set to false, we will enable the
#                                  default puppetmaster service unless
#                                  service_fallback is set to false. See 'Advanced
#                                  server parameters' for more information.
#                                  Only applicable when server_implementation is "master".
#                                  type:boolean
#
# $server_external_nodes::         External nodes classifier executable
#
# $server_template::               Which template should be used for master
#                                  configuration
#
# $server_git_repo::               Use git repository as a source of modules
#                                  type:boolean
#
# $server_dynamic_environments::   Use $environment in the modulepath
#                                  Deprecated when $server_directory_environments is true,
#                                  set $server_environments to [] instead.
#                                  type:boolean
#
# $server_directory_environments:: Enable directory environments, defaulting to true
#                                  with Puppet 3.6.0 or higher
#                                  type:boolean
#
# $server_environments::           Environments to setup (creates directories).
#                                  Applies only when $server_dynamic_environments
#                                  is false
#                                  type:array
#
# $server_environments_owner::     The owner of the environments directory
#
# $server_environments_group::     The group owning the environments directory
#
# $server_environments_mode::      Environments directory mode.
#
# $server_envs_dir::               Directory that holds puppet environments
#
# $server_manifest_path::          Path to puppet site.pp manifest (only when
#                                  $server_git_repo_path and $server_dynamic_environments
#                                  are false)
#
# $server_common_modules_path::    Common modules paths (only when
#                                  $server_git_repo_path and $server_dynamic_environments
#                                  are false)
#                                  type:array
#
# $server_git_repo_path::          Git repository path
#
# $server_git_branch_map::         Git branch to puppet env mapping for the
#                                  default post receive hook
#                                  type:hash
#
# $server_post_hook_content::      Which template to use for git post hook
#
# $server_post_hook_name::         Name of a git hook
#
# $server_storeconfigs_backend::   Do you use storeconfigs? (note: not required)
#                                  false if you don't, "active_record" for 2.X
#                                  style db, "puppetdb" for puppetdb
#
# $server_app_root::               Directory where the application lives
#
# $server_ssl_dir::                SSL directory
#
# $server_package::                Custom package name for puppet master
#
# $server_certname::               The name to use when handling certificates.
#
# $server_strict_variables::       if set to true, it will throw parse errors
#                                  when accessing undeclared variables.
#                                  type:boolean
#
# === Advanced server parameters:
#
# $server_httpd_service::          Apache/httpd service name to notify
#                                  on configuration changes. Defaults
#                                  to 'httpd' based on the default
#                                  apache module included with foreman-installer.
#
# $server_service_fallback::       If passenger is not used, do we want to fallback
#                                  to using the puppetmaster service? Set to false
#                                  if you disabled passenger and you do NOT want to
#                                  use the puppetmaster service. Defaults to true.
#                                  type:boolean
#
# $server_passenger_max_pool::     The PassengerMaxPoolSize parameter. If your
#                                  host is low on memory, it may be a good thing
#                                  to lower this. Defaults to 12.
#                                  type:integer
#
# $server_config_version::         How to determine the configuration version. When
#                                  using git_repo, by default a git describe
#                                  approach will be installed.
#
# $server_facts::                  Should foreman receive facts from puppet
#                                  type:boolean
#
# $server_foreman_url::            Foreman URL
#
# $server_foreman_ssl_ca::         SSL CA of the Foreman server
#
# $server_foreman_ssl_cert::       Client certificate for authenticating against Foreman server
#
# $server_foreman_ssl_key::        Key for authenticating against Foreman server
#
#
# $server_puppet_basedir::         Where is the puppet code base located
#
# $server_puppet_home::            Puppet var directory
#
# $server_enc_api::                What version of enc script to deploy. Valid
#                                  values are 'v2' for latest, and 'v1'
#                                  for Foreman =< 1.2
#
# $server_report_api::             What version of report processor to deploy.
#                                  Valid values are 'v2' for latest, and 'v1'
#                                  for Foreman =< 1.2
#
# $server_ca_proxy::               The actual server that handles puppet CA.
#                                  Setting this to anything non-empty causes
#                                  the apache vhost to set up a proxy for all
#                                  certificates pointing to the value.
#
# $allow_any_crl_auth::            Allow any authentication for the CRL. This
#                                  is needed on the puppet CA to accept clients
#                                  from a the puppet CA proxy.
#                                  type:boolean
#
# $auth_allowed::                  An array of authenticated nodes allowed to
#                                  access all catalog and node endpoints.
#                                  default to ['$1']
#                                  type:array
#
# === Usage:
#
# * Simple usage:
#
#     include puppet
#
# * Installing a puppetmaster
#
#   class {'puppet':
#     server => true,
#   }
#
# * Advanced usage:
#
#   class {'puppet':
#     agent_noop => true,
#     version    => '2.7.20-1',
#   }
#
class puppet (
  $version                       = $puppet::params::version,
  $user                          = $puppet::params::user,
  $group                         = $puppet::params::group,
  $dir                           = $puppet::params::dir,
  $port                          = $puppet::params::port,
  $listen                        = $puppet::params::listen,
  $pluginsync                    = $puppet::params::pluginsync,
  $splay                         = $puppet::params::splay,
  $splaylimit                    = $puppet::params::splaylimit,
  $runinterval                   = $puppet::params::runinterval,
  $usecacheonfailure             = $puppet::params::usecacheonfailure,
  $runmode                       = $puppet::params::runmode,
  $cron_cmd                      = $puppet::params::cron_cmd,
  $agent_noop                    = $puppet::params::agent_noop,
  $show_diff                     = $puppet::params::show_diff,
  $configtimeout                 = $puppet::params::configtimeout,
  $ca_server                     = $puppet::params::ca_server,
  $dns_alt_names                 = $puppet::params::dns_alt_names,
  $use_srv_records               = $puppet::params::use_srv_records,
  $srv_domain                    = $puppet::params::srv_domain,
  $pluginsource                  = $puppet::params::pluginsource,
  $classfile                     = $puppet::params::classfile,
  $hiera_config                  = $puppet::params::hiera_config,
  $main_template                 = $puppet::params::main_template,
  $agent_template                = $puppet::params::agent_template,
  $auth_template                 = $puppet::params::auth_template,
  $nsauth_template               = $puppet::params::nsauth_template,
  $allow_any_crl_auth            = $puppet::params::allow_any_crl_auth,
  $auth_allowed                  = $puppet::params::auth_allowed,
  $client_package                = $puppet::params::client_package,
  $agent                         = $puppet::params::agent,
  $puppetmaster                  = $puppet::params::puppetmaster,
  $syslogfacility                = $puppet::params::syslogfacility,
  $server                        = $puppet::params::server,
  $server_user                   = $puppet::params::user,
  $server_group                  = $puppet::params::group,
  $server_dir                    = $puppet::params::dir,
  $server_port                   = $puppet::params::port,
  $server_vardir                 = $puppet::params::server_vardir,
  $server_ca                     = $puppet::params::server_ca,
  $server_reports                = $puppet::params::server_reports,
  $server_implementation         = $puppet::params::server_implementation,
  $server_passenger              = $puppet::params::server_passenger,
  $server_service_fallback       = $puppet::params::server_service_fallback,
  $server_passenger_max_pool     = $puppet::params::server_passenger_max_pool,
  $server_httpd_service          = $puppet::params::server_httpd_service,
  $server_external_nodes         = $puppet::params::server_external_nodes,
  $server_template               = $puppet::params::server_template,
  $server_config_version         = $puppet::params::server_config_version,
  $server_git_repo               = $puppet::params::server_git_repo,
  $server_dynamic_environments   = $puppet::params::server_dynamic_environments,
  $server_directory_environments = $puppet::params::server_directory_environments,
  $server_environments           = $puppet::params::server_environments,
  $server_environments_owner     = $puppet::params::server_environments_owner,
  $server_environments_group     = $puppet::params::server_environments_group,
  $server_environments_mode      = $puppet::params::server_environments_mode,
  $server_envs_dir               = $puppet::params::server_envs_dir,
  $server_manifest_path          = $puppet::params::server_manifest_path,
  $server_common_modules_path    = $puppet::params::server_common_modules_path,
  $server_git_repo_path          = $puppet::params::server_git_repo_path,
  $server_git_branch_map         = $puppet::params::server_git_branch_map,
  $server_post_hook_content      = $puppet::params::server_post_hook_content,
  $server_post_hook_name         = $puppet::params::server_post_hook_name,
  $server_storeconfigs_backend   = $puppet::params::server_storeconfigs_backend,
  $server_app_root               = $puppet::params::server_app_root,
  $server_ssl_dir                = $puppet::params::server_ssl_dir,
  $server_package                = $puppet::params::server_package,
  $server_certname               = $puppet::params::server_certname,
  $server_enc_api                = $puppet::params::server_enc_api,
  $server_report_api             = $puppet::params::server_report_api,
  $server_ca_proxy               = $puppet::params::server_ca_proxy,
  $server_strict_variables       = $puppet::params::server_strict_variables,
  $server_foreman_url            = $foreman::params::foreman_url,
  $server_foreman_ssl_ca         = $foreman::params::client_ssl_ca,
  $server_foreman_ssl_cert       = $foreman::params::client_ssl_cert,
  $server_foreman_ssl_key        = $foreman::params::client_ssl_key,
  $server_facts                  = $foreman::params::facts,
  $server_puppet_home            = $foreman::params::puppet_home,
  $server_puppet_basedir         = $foreman::params::puppet_basedir
) inherits puppet::params {

  validate_bool($listen)
  validate_bool($pluginsync)
  validate_bool($splay)
  validate_bool($usecacheonfailure)
  validate_bool($agent_noop)
  validate_bool($agent)
  validate_bool($server)
  validate_bool($allow_any_crl_auth)
  validate_bool($server_ca)
  validate_bool($server_passenger)
  validate_bool($server_git_repo)
  validate_bool($server_service_fallback)
  validate_bool($server_facts)
  validate_bool($server_strict_variables)

  validate_string($ca_server)
  validate_string($hiera_config)
  validate_string($server_external_nodes)
  validate_string($server_ca_proxy)

  validate_array($dns_alt_names)
  validate_array($auth_allowed)

  validate_re($server_implementation, '^(master|puppetserver)$')

  include ::puppet::config
  Class['puppet::config'] -> Class['puppet']

  if $agent == true {
    include ::puppet::agent
    Class['puppet::agent'] -> Class['puppet']
  }

  if $server == true {
    include ::puppet::server
    Class['puppet::server'] -> Class['puppet']
  }
}
