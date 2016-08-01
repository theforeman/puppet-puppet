# == Class: puppet
#
# This class installs and configures the puppet agent.
#
# === Parameters:
#
# $version::                          Specify a specific version of a package to
#                                     install. The version should be the exact
#                                     match for your distro.
#                                     You can also use certain values like 'latest'.
#                                     type:string
#
# $user::                             Override the name of the puppet user.
#                                     type:string
#
# $group::                            Override the name of the puppet group.
#                                     type:string
#
# $dir::                              Override the puppet directory.
#                                     type:string
#
# $codedir::                          Override the puppet code directory.
#                                     type:string
#
# $vardir::                           Override the puppet var directory.
#                                     type:string
#
# $logdir::                           Override the log directory.
#                                     type:string
#
# $rundir::                           Override the PID directory.
#                                     type:string
#
# $ssldir::                           Override where SSL certificates are kept.
#                                     type:string
#
# $sharedir::                         Override the system data directory.
#                                     type:string
#
# $manage_packages::                  Should this module install packages or not.
#                                     Can also install only server packages with value
#                                     of 'server' or only agent packages with 'agent'.
#                                     Defaults to true
#
# $package_provider::                 The provider used to install the agent.
#                                     Defaults to chocolatey on Windows
#                                     Defaults to undef elsewhere
#                                     type:string
#
# $package_source::                   The location of the file to be used by the
#                                     agent's package resource.
#                                     Defaults to undef. If 'windows' or 'msi' are
#                                     used as the provider then this setting is
#                                     required.
#                                     type:string
#
# $port::                             Override the port of the master we connect to.
#                                     type:integer
#
# $listen::                           Should the puppet agent listen for connections.
#                                     type:boolean
#
# $listen_to::                        An array of servers allowed to initiate a puppet run.
#                                     If $listen = true one of three things will happen:
#                                     1) if $listen_to is not empty then this array
#                                     will be used.
#                                     2) if $listen_to is empty and $puppetmaster is
#                                     defined then only $puppetmaster will be
#                                     allowed.
#                                     3) if $puppetmaster is not defined or empty,
#                                     $fqdn will be used.
#                                     type:array
#
# $pluginsync::                       Enable pluginsync.
#                                     type:boolean
#
# $splay::                            Switch to enable a random amount of time
#                                     to sleep before each run.
#                                     type:boolean
#
# $splaylimit::                       The maximum time to delay before runs.
#                                     Defaults to being the same as the run interval.
#                                     This setting can be a time interval in seconds
#                                     (30 or 30s), minutes (30m), hours (6h), days (2d),
#                                     or years (5y).
#                                     type:string
#
# $runinterval::                      Set up the interval (in seconds) to run
#                                     the puppet agent.
#                                     type:integer
#
# $autosign::                         If set to a boolean, autosign is enabled or disabled
#                                     for all incoming requests. Otherwise this has to be
#                                     set to the full file path of an autosign.conf file or
#                                     an autosign script. If this is set to a script, make
#                                     sure that script considers the content of autosign.conf
#                                     as otherwise Foreman functionality might be broken.
#
# $autosign_mode::                    mode of the autosign file/script
#
# $usecacheonfailure::                Switch to enable use of cached catalog on
#                                     failure of run.
#                                     type: boolean
#
# $runmode::                          Select the mode to setup the puppet agent.
#                                     Can be either 'cron', 'service',
#                                     'systemd.timer', or 'none'.
#                                     type:string
#
# $unavailable_runmodes::             Runmodes that are not available for the
#                                     current system. This module will not try
#                                     to disable these modes. Default is []
#                                     on Linux, ['cron', 'systemd.timer'] on
#                                     Windows and ['systemd.timer'] on other
#                                     systems.
#                                     type: array
#
# $cron_cmd::                         Specify command to launch when runmode is
#                                     set 'cron'.
#                                     type:string
#
# $systemd_cmd::                      Specify command to launch when runmode is
#                                     set 'systemd.timer'.
#                                     type:string
#
# $show_diff::                        Show and report changed files with diff output
#                                     type:boolean
#
# $module_repository::                Use a different puppet module repository
#                                     type:string
#
# $configtimeout::                    How long the client should wait for the
#                                     configuration to be retrieved before
#                                     considering it a failure.
#                                     type:integer
#
# $ca_server::                        Use a different ca server. Should be either
#                                     a string with the location of the ca_server
#                                     or 'false'.
#                                     type:string
#
# $ca_port::                          Puppet CA port
#                                     type:integer
#
# $dns_alt_names::                    Use additional DNS names when generating a
#                                     certificate.  Defaults to an empty Array.
#                                     type:array
#
# $classfile::                        The file in which puppet agent stores a list
#                                     of the classes associated with the retrieved
#                                     configuration.
#                                     type:string
#
# $hiera_config::                     The hiera configuration file.
#                                     type:string
#
# $syslogfacility::                   Facility name to use when logging to syslog
#                                     type:string
#
# $auth_template::                    Use a custom template for the auth
#                                     configuration.
#                                     type:string
#
# $main_template::                    Use a custom template for the main puppet
#                                     configuration.
#                                     type:string
#
# $use_srv_records::                  Whether DNS SRV records will be used to resolve
#                                     the Puppet master
#                                     type:boolean
#
# $srv_domain::                       Search domain for SRV records
#                                     type:string
#
# $pluginsource::                     URL to retrieve Puppet plugins from during pluginsync
#                                     type:string
#
# $pluginfactsource::                 URL to retrieve Puppet facts from during pluginsync
#                                     type:string
#
# $additional_settings::              A hash of additional main settings.
#                                     type:hash
#
# == puppet::agent parameters
#
# $agent::                            Should a puppet agent be installed
#                                     type:boolean
#
# $agent_noop::                       Run the agent in noop mode.
#                                     type:boolean
#
# $agent_template::                   Use a custom template for the agent puppet
#                                     configuration.
#                                     type:string
#
# $client_package::                   Install a custom package to provide
#                                     the puppet client
#                                     type:array
#
# $puppetmaster::                     Hostname of your puppetmaster (server
#                                     directive in puppet.conf)
#                                     type:string
#
# $prerun_command::                   A command which gets excuted before each Puppet run
#                                     type:string
#
# $postrun_command::                  A command which gets excuted after each Puppet run
#                                     type:string
#
# $systemd_unit_name::                The name of the puppet systemd units.
#                                     type:string
#
# $service_name::                     The name of the puppet agent service.
#                                     type:string
#
# $agent_restart_command::            The command which gets excuted on puppet service restart
#                                     type:string
#
# $environment::                      Default environment of the Puppet agent
#                                     type:string
#
# $agent_additional_settings::        A hash of additional agent settings.
#                                     Example: {stringify_facts => true}
#                                     type:hash
#
# $remove_lock::                      Remove the agent lock when running.
#                                     type:boolean
#
# $client_certname::                  The node's certificate name, and the unique
#                                     identifier it uses when requesting catalogs.
#                                     type:string
#
# $dir_owner::                        Owner of the base puppet directory, used when
#                                     puppet::server is false.
#                                     type:string
#
# $dir_group::                        Group of the base puppet directory, used when
#                                     puppet::server is false.
#                                     type:string
#
# == puppet::server parameters
#
# $server::                           Should a puppet master be installed as well as the client
#                                     type:boolean
#
# $server_user::                      Name of the puppetmaster user.
#                                     type:string
#
# $server_group::                     Name of the puppetmaster group.
#                                     type:string
#
# $server_dir::                       Puppet configuration directory
#                                     type:string
#
# $server_ip::                        Bind ip address of the puppetmaster
#                                     type:string
#
# $server_port::                      Puppet master port
#                                     type:integer
#
# $server_ca::                        Provide puppet CA
#                                     type:boolean
#
# $server_http::                      Should the puppet master listen on HTTP as well as HTTPS.
#                                     Useful for load balancer or reverse proxy scenarios. Note that
#                                     the HTTP puppet master denies access from all clients by default,
#                                     allowed clients must be specified with $server_http_allow.
#                                     type:boolean
#
# $server_http_port::                 Puppet master HTTP port; defaults to 8139.
#                                     type:integer
#
# $server_http_allow::                Array of allowed clients for the HTTP puppet master. Passed
#                                     to Apache's 'Allow' directive.
#                                     type:array
#
# $server_reports::                   List of report types to include on the puppetmaster
#                                     type:string
#
# $server_implementation::            Puppet master implementation, either "master" (traditional
#                                     Ruby) or "puppetserver" (JVM-based)
#                                     type:string
#
# $server_passenger::                 If set to true, we will configure apache with
#                                     passenger. If set to false, we will enable the
#                                     default puppetmaster service unless
#                                     service_fallback is set to false. See 'Advanced
#                                     server parameters' for more information.
#                                     Only applicable when server_implementation is "master".
#                                     type:boolean
#
# $server_external_nodes::            External nodes classifier executable
#                                     type:string
#
# $server_template::                  Which template should be used for master
#                                     configuration
#                                     type:string
#
# $server_main_template::             Which template should be used for master
#                                     related configuration in the [main] section
#                                     type:string
#
# $server_git_repo::                  Use git repository as a source of modules
#                                     type:boolean
#
# $server_dynamic_environments::      Use $environment in the modulepath
#                                     Deprecated when $server_directory_environments is true,
#                                     set $server_environments to [] instead.
#                                     type:boolean
#
# $server_directory_environments::    Enable directory environments, defaulting to true
#                                     with Puppet 3.6.0 or higher
#                                     type:boolean
#
# $server_environments::              Environments to setup (creates directories).
#                                     Applies only when $server_dynamic_environments
#                                     is false
#                                     type:array
#
# $server_environments_owner::        The owner of the environments directory
#                                     type:string
#
# $server_environments_group::        The group owning the environments directory
#                                     type:string
#
# $server_environments_mode::         Environments directory mode.
#                                     type:string
#
# $server_envs_dir::                  Directory that holds puppet environments
#                                     type:string
#
# $server_envs_target::               Indicates that $envs_dir should be
#                                     a symbolic link to this target
#                                     type:string
#
# $server_common_modules_path::       Common modules paths (only when
#                                     $server_git_repo_path and $server_dynamic_environments
#                                     are false)
#                                     type:array
#
# $server_git_repo_path::             Git repository path
#                                     type:string
#
# $server_git_repo_mode::             Git repository mode
#                                     type:string
#
# $server_git_repo_group::            Git repository group
#                                     type:string
#
# $server_git_repo_user::             Git repository user
#                                     type:string
#
# $server_git_branch_map::            Git branch to puppet env mapping for the
#                                     default post receive hook
#                                     type:hash
#
# $server_post_hook_content::         Which template to use for git post hook
#                                     type:string
#
# $server_post_hook_name::            Name of a git hook
#                                     type:string
#
# $server_storeconfigs_backend::      Do you use storeconfigs? (note: not required)
#                                     false if you don't, "active_record" for 2.X
#                                     style db, "puppetdb" for puppetdb
#                                     type:string
#
# $server_app_root::                  Directory where the application lives
#                                     type:string
#
# $server_ssl_dir::                   SSL directory
#                                     type:string
#
# $server_package::                   Custom package name for puppet master
#                                     type:string
#
# $server_version::                   Custom package version for puppet master
#                                     type:string
#
# $server_certname::                  The name to use when handling certificates.
#                                     type:string
#
# $server_strict_variables::          if set to true, it will throw parse errors
#                                     when accessing undeclared variables.
#                                     type:boolean
#
# $server_additional_settings::       A hash of additional settings.
#                                     Example: {trusted_node_data => true, ordering => 'manifest'}
#                                     type:hash
#
# $server_rack_arguments::            Arguments passed to rack app ARGV in addition to --confdir and
#                                     --vardir.  The default is an empty array.
#                                     type:array
#
# $server_puppetdb_host::             PuppetDB host
#                                     type:string
#
# $server_puppetdb_port::             PuppetDB port
#                                     type:integer
#
# $server_puppetdb_swf::              PuppetDB soft_write_failure
#                                     type:boolean
#
# $server_parser::                    Sets the parser to use. Valid options are 'current' or 'future'.
#                                     Defaults to 'current'.
#                                     type:string
#
# === Advanced server parameters:
#
# $server_httpd_service::             Apache/httpd service name to notify
#                                     on configuration changes. Defaults
#                                     to 'httpd' based on the default
#                                     apache module included with foreman-installer.
#                                     type:string
#
# $server_service_fallback::          If passenger is not used, do we want to fallback
#                                     to using the puppetmaster service? Set to false
#                                     if you disabled passenger and you do NOT want to
#                                     use the puppetmaster service. Defaults to true.
#                                     type:boolean
#
# $server_passenger_min_instances::   The PassengerMinInstances parameter. Sets the
#                                     minimum number of application processes to run.
#                                     Defaults to the number of processors on your
#                                     system.
#                                     type:integer
#
# $server_passenger_pre_start::       Pre-start the first passenger worker instance
#                                     process during httpd start.
#                                     type:boolean
#
# $server_passenger_ruby::            The PassengerRuby parameter. Sets the Ruby
#                                     interpreter for serving the puppetmaster
#                                     rack application.
#                                     type:string
#
# $server_config_version::            How to determine the configuration version. When
#                                     using git_repo, by default a git describe
#                                     approach will be installed.
#                                     type:string
#
# $server_facts::                     Should foreman receive facts from puppet
#                                     type:boolean
#
# $server_foreman::                   Should foreman integration be installed
#                                     type:boolean
#
# $server_foreman_url::               Foreman URL
#                                     type:string
#
# $server_foreman_ssl_ca::            SSL CA of the Foreman server
#                                     type:string
#
# $server_foreman_ssl_cert::          Client certificate for authenticating against Foreman server
#                                     type:string
#
# $server_foreman_ssl_key::           Key for authenticating against Foreman server
#                                     type:string
#
# $server_puppet_basedir::            Where is the puppet code base located
#                                     type:string
#
# $server_enc_api::                   What version of enc script to deploy. Valid
#                                     values are 'v2' for latest, and 'v1'
#                                     for Foreman =< 1.2
#                                     type:string
#
# $server_report_api::                What version of report processor to deploy.
#                                     Valid values are 'v2' for latest, and 'v1'
#                                     for Foreman =< 1.2
#                                     type:string
#
# $server_request_timeout::           Timeout in node.rb script for fetching
#                                     catalog from Foreman (in seconds).
#                                     type:integer
#
# $server_environment_timeout::       Timeout for cached compiled catalogs (10s, 5m, ...)
#                                     type:string
#
# $server_ca_proxy::                  The actual server that handles puppet CA.
#                                     Setting this to anything non-empty causes
#                                     the apache vhost to set up a proxy for all
#                                     certificates pointing to the value.
#                                     type:string
#
# $server_jvm_java_bin::              Set the default java to use.
#                                     type:string
#
# $server_jvm_config::                Specify the puppetserver jvm configuration file.
#                                     type:string
#
# $server_jvm_min_heap_size::         Specify the minimum jvm heap space.
#                                     type:string
#
# $server_jvm_max_heap_size::         Specify the maximum jvm heap space.
#                                     type:string
#
# $server_jvm_extra_args::            Additional java options to pass through.
#                                     This can be used for Java versions prior to
#                                     Java 8 to specify the max perm space to use:
#                                     For example: '-XX:MaxPermSpace=128m'.
#                                     type:string
#
# $server_jruby_gem_home::            Where jruby gems are located for puppetserver
#                                     type:string
#
# $allow_any_crl_auth::               Allow any authentication for the CRL. This
#                                     is needed on the puppet CA to accept clients
#                                     from a the puppet CA proxy.
#                                     type:boolean
#
# $auth_allowed::                     An array of authenticated nodes allowed to
#                                     access all catalog and node endpoints.
#                                     default to ['$1']
#                                     type:array
#
# $server_default_manifest::          Toggle if default_manifest setting should
#                                     be added to the [main] section
#                                     type:boolean
#
# $server_default_manifest_path::     A string setting the path to the default_manifest
#                                     type:string
#
# $server_default_manifest_content::  A string to set the content of the default_manifest
#                                     If set to '' it will not manage the file
#                                     type:string
#
# $server_ssl_dir_manage::            Toggle if ssl_dir should be added to the [master]
#                                     configuration section. This is necessary to
#                                     disable in case CA is delegated to a separate instance
#                                     type:boolean
#
# $server_puppetserver_dir::          The path of the puppetserver config dir
#                                     type:string
#
# $server_puppetserver_version::      The version of puppetserver 2 installed (or being installed)
#                                     Unfortunately, different versions of puppetserver need configuring differently,
#                                     and there's no easy way of determining which version is being installed.
#                                     Defaults to '2.3.1' but can be overriden if you're installing an older version.
#                                     type:string
#
# $server_max_active_instances::      Max number of active jruby instances. Defaults to
#                                     processor count
#                                     type:integer
#
# $server_idle_timeout::              How long the server will wait for a response on an existing connection
#                                     type:integer
#
# $server_connect_timeout::           How long the server will wait for a response to a connection attempt
#                                     type:integer
#
# $server_ssl_protocols::             Array of SSL protocols to use.
#                                     Defaults to [ 'TLSv1.2' ]
#                                     type:array
#
# $server_cipher_suites::             List of SSL ciphers to use in negotiation
#                                     Defaults to [ 'TLS_RSA_WITH_AES_256_CBC_SHA256', 'TLS_RSA_WITH_AES_256_CBC_SHA',
#                                     'TLS_RSA_WITH_AES_128_CBC_SHA256', 'TLS_RSA_WITH_AES_128_CBC_SHA', ]
#                                     type:array
#
# $server_ruby_load_paths::           List of ruby paths
#                                     Defaults based on $::puppetversion
#                                     type:array
#
# $server_ca_client_whitelist::       The whitelist of client certificates that
#                                     can query the certificate-status endpoint
#                                     Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#                                     type:array
#
# $server_admin_api_whitelist::       The whitelist of clients that
#                                     can query the puppet-admin-api endpoint
#                                     Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#                                     type:array
#
# $server_enable_ruby_profiler::      Should the puppetserver ruby profiler be enabled?
#                                     Defaults to false
#                                     type:boolean
#
# $server_ca_auth_required::          Whether client certificates are needed to access the puppet-admin api
#                                     Defaults to true
#                                     type:boolean
#
# $server_use_legacy_auth_conf::      Should the puppetserver use the legacy puppet auth.conf?
#                                     Defaults to false (the puppetserver will use its own conf.d/auth.conf)
#                                     type:boolean
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
  $version                         = $puppet::params::version,
  $user                            = $puppet::params::user,
  $group                           = $puppet::params::group,
  $dir                             = $puppet::params::dir,
  $codedir                         = $puppet::params::codedir,
  $vardir                          = $puppet::params::vardir,
  $logdir                          = $puppet::params::logdir,
  $rundir                          = $puppet::params::rundir,
  $ssldir                          = $puppet::params::ssldir,
  $sharedir                        = $puppet::params::sharedir,
  $manage_packages                 = $puppet::params::manage_packages,
  $dir_owner                       = $puppet::params::dir_owner,
  $dir_group                       = $puppet::params::dir_group,
  $package_provider                = $puppet::params::package_provider,
  $package_source                  = $puppet::params::package_source,
  $port                            = $puppet::params::port,
  $listen                          = $puppet::params::listen,
  $listen_to                       = $puppet::params::listen_to,
  $pluginsync                      = $puppet::params::pluginsync,
  $splay                           = $puppet::params::splay,
  $splaylimit                      = $puppet::params::splaylimit,
  $autosign                        = $puppet::params::autosign,
  $autosign_mode                   = $puppet::params::autosign_mode,
  $runinterval                     = $puppet::params::runinterval,
  $usecacheonfailure               = $puppet::params::usecacheonfailure,
  $runmode                         = $puppet::params::runmode,
  $unavailable_runmodes            = $puppet::params::unavailable_runmodes,
  $cron_cmd                        = $puppet::params::cron_cmd,
  $systemd_cmd                     = $puppet::params::systemd_cmd,
  $agent_noop                      = $puppet::params::agent_noop,
  $show_diff                       = $puppet::params::show_diff,
  $module_repository               = $puppet::params::module_repository,
  $configtimeout                   = $puppet::params::configtimeout,
  $ca_server                       = $puppet::params::ca_server,
  $ca_port                         = $puppet::params::ca_port,
  $prerun_command                  = $puppet::params::prerun_command,
  $postrun_command                 = $puppet::params::postrun_command,
  $dns_alt_names                   = $puppet::params::dns_alt_names,
  $use_srv_records                 = $puppet::params::use_srv_records,
  $srv_domain                      = $puppet::params::srv_domain,
  $pluginsource                    = $puppet::params::pluginsource,
  $pluginfactsource                = $puppet::params::pluginfactsource,
  $additional_settings             = $puppet::params::additional_settings,
  $agent_additional_settings       = $puppet::params::agent_additional_settings,
  $agent_restart_command           = $puppet::params::agent_restart_command,
  $classfile                       = $puppet::params::classfile,
  $hiera_config                    = $puppet::params::hiera_config,
  $main_template                   = $puppet::params::main_template,
  $agent_template                  = $puppet::params::agent_template,
  $auth_template                   = $puppet::params::auth_template,
  $allow_any_crl_auth              = $puppet::params::allow_any_crl_auth,
  $auth_allowed                    = $puppet::params::auth_allowed,
  $client_package                  = $puppet::params::client_package,
  $agent                           = $puppet::params::agent,
  $remove_lock                     = $puppet::params::remove_lock,
  $client_certname                 = $puppet::params::client_certname,
  $puppetmaster                    = $puppet::params::puppetmaster,
  $systemd_unit_name               = $puppet::params::systemd_unit_name,
  $service_name                    = $puppet::params::service_name,
  $syslogfacility                  = $puppet::params::syslogfacility,
  $environment                     = $puppet::params::environment,
  $server                          = $puppet::params::server,
  $server_admin_api_whitelist      = $puppet::params::server_admin_api_whitelist,
  $server_user                     = $puppet::params::user,
  $server_group                    = $puppet::params::group,
  $server_dir                      = $puppet::params::dir,
  $server_ip                       = $puppet::params::ip,
  $server_port                     = $puppet::params::port,
  $server_ca                       = $puppet::params::server_ca,
  $server_ca_auth_required         = $puppet::params::server_ca_auth_required,
  $server_ca_client_whitelist      = $puppet::params::server_ca_client_whitelist,
  $server_http                     = $puppet::params::server_http,
  $server_http_port                = $puppet::params::server_http_port,
  $server_http_allow               = $puppet::params::server_http_allow,
  $server_reports                  = $puppet::params::server_reports,
  $server_implementation           = $puppet::params::server_implementation,
  $server_passenger                = $puppet::params::server_passenger,
  $server_puppetserver_dir         = $puppet::params::server_puppetserver_dir,
  $server_puppetserver_version     = $puppet::params::server_puppetserver_version,
  $server_service_fallback         = $puppet::params::server_service_fallback,
  $server_passenger_min_instances  = $puppet::params::server_passenger_min_instances,
  $server_passenger_pre_start      = $puppet::params::server_passenger_pre_start,
  $server_passenger_ruby           = $puppet::params::server_passenger_ruby,
  $server_httpd_service            = $puppet::params::server_httpd_service,
  $server_external_nodes           = $puppet::params::server_external_nodes,
  $server_template                 = $puppet::params::server_template,
  $server_main_template            = $puppet::params::server_main_template,
  $server_cipher_suites            = $puppet::params::server_cipher_suites,
  $server_config_version           = $puppet::params::server_config_version,
  $server_connect_timeout          = $puppet::params::server_connect_timeout,
  $server_git_repo                 = $puppet::params::server_git_repo,
  $server_dynamic_environments     = $puppet::params::server_dynamic_environments,
  $server_directory_environments   = $puppet::params::server_directory_environments,
  $server_default_manifest         = $puppet::params::server_default_manifest,
  $server_default_manifest_path    = $puppet::params::server_default_manifest_path,
  $server_default_manifest_content = $puppet::params::server_default_manifest_content,
  $server_enable_ruby_profiler     = $puppet::params::server_enable_ruby_profiler,
  $server_environments             = $puppet::params::server_environments,
  $server_environments_owner       = $puppet::params::server_environments_owner,
  $server_environments_group       = $puppet::params::server_environments_group,
  $server_environments_mode        = $puppet::params::server_environments_mode,
  $server_envs_dir                 = $puppet::params::server_envs_dir,
  $server_envs_target              = $puppet::params::server_envs_target,
  $server_common_modules_path      = $puppet::params::server_common_modules_path,
  $server_git_repo_mode            = $puppet::params::server_git_repo_mode,
  $server_git_repo_path            = $puppet::params::server_git_repo_path,
  $server_git_repo_group           = $puppet::params::server_git_repo_group,
  $server_git_repo_user            = $puppet::params::server_git_repo_user,
  $server_git_branch_map           = $puppet::params::server_git_branch_map,
  $server_idle_timeout             = $puppet::params::server_idle_timeout,
  $server_post_hook_content        = $puppet::params::server_post_hook_content,
  $server_post_hook_name           = $puppet::params::server_post_hook_name,
  $server_storeconfigs_backend     = $puppet::params::server_storeconfigs_backend,
  $server_app_root                 = $puppet::params::server_app_root,
  $server_ruby_load_paths          = $puppet::params::server_ruby_load_paths,
  $server_ssl_dir                  = $puppet::params::server_ssl_dir,
  $server_ssl_dir_manage           = $puppet::params::server_ssl_dir_manage,
  $server_ssl_protocols            = $puppet::params::server_ssl_protocols,
  $server_package                  = $puppet::params::server_package,
  $server_version                  = $puppet::params::server_version,
  $server_certname                 = $puppet::params::server_certname,
  $server_enc_api                  = $puppet::params::server_enc_api,
  $server_report_api               = $puppet::params::server_report_api,
  $server_request_timeout          = $puppet::params::server_request_timeout,
  $server_ca_proxy                 = $puppet::params::server_ca_proxy,
  $server_strict_variables         = $puppet::params::server_strict_variables,
  $server_additional_settings      = $puppet::params::server_additional_settings,
  $server_rack_arguments           = $puppet::params::server_rack_arguments,
  $server_foreman                  = $puppet::params::server_foreman,
  $server_foreman_url              = $puppet::params::server_foreman_url,
  $server_foreman_ssl_ca           = $puppet::params::server_foreman_ssl_ca,
  $server_foreman_ssl_cert         = $puppet::params::server_foreman_ssl_cert,
  $server_foreman_ssl_key          = $puppet::params::server_foreman_ssl_key,
  $server_facts                    = $puppet::params::server_facts,
  $server_puppet_basedir           = $puppet::params::server_puppet_basedir,
  $server_puppetdb_host            = $puppet::params::server_puppetdb_host,
  $server_puppetdb_port            = $puppet::params::server_puppetdb_port,
  $server_puppetdb_swf             = $puppet::params::server_puppetdb_swf,
  $server_parser                   = $puppet::params::server_parser,
  $server_environment_timeout      = $puppet::params::server_environment_timeout,
  $server_jvm_java_bin             = $puppet::params::server_jvm_java_bin,
  $server_jvm_config               = $puppet::params::server_jvm_config,
  $server_jvm_min_heap_size        = $puppet::params::server_jvm_min_heap_size,
  $server_jvm_max_heap_size        = $puppet::params::server_jvm_max_heap_size,
  $server_jvm_extra_args           = $puppet::params::server_jvm_extra_args,
  $server_jruby_gem_home           = $puppet::params::server_jruby_gem_home,
  $server_max_active_instances     = $puppet::params::server_max_active_instances,
  $server_use_legacy_auth_conf     = $puppet::params::server_use_legacy_auth_conf,
) inherits puppet::params {

  validate_bool($listen)
  validate_bool($pluginsync)
  validate_bool($splay)
  validate_bool($usecacheonfailure)
  validate_bool($agent_noop)
  validate_bool($agent)
  validate_bool($remove_lock)
  validate_bool($server)
  validate_bool($allow_any_crl_auth)

  validate_hash($additional_settings)
  validate_hash($agent_additional_settings)

  if $ca_server {
    validate_string($ca_server)
  }

  validate_string($systemd_unit_name)

  validate_string($service_name)

  validate_array($listen_to)
  validate_array($dns_alt_names)
  validate_array($auth_allowed)

  validate_absolute_path($dir)
  validate_absolute_path($vardir)
  validate_absolute_path($logdir)
  validate_absolute_path($rundir)

  if $manage_packages != true and $manage_packages != false {
    validate_re($manage_packages, '^(server|agent)$')
  }

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
