# == Class: puppet
#
# This class installs and configures the puppet agent.
#
# === Parameters:
#
# $version::                                Specify a specific version of a package to
#                                           install. The version should be the exact
#                                           match for your distro.
#                                           You can also use certain values like 'latest'.
#                                           type:String
#
# $user::                                   Override the name of the puppet user.
#                                           type:String
#
# $group::                                  Override the name of the puppet group.
#                                           type:String
#
# $dir::                                    Override the puppet directory.
#                                           type:Stdlib::Absolutepath
#
# $codedir::                                Override the puppet code directory.
#                                           type:Stdlib::Absolutepath
#
# $vardir::                                 Override the puppet var directory.
#                                           type:Stdlib::Absolutepath
#
# $logdir::                                 Override the log directory.
#                                           type:Stdlib::Absolutepath
#
# $rundir::                                 Override the PID directory.
#                                           type:Stdlib::Absolutepath
#
# $ssldir::                                 Override where SSL certificates are kept.
#                                           type:Stdlib::Absolutepath
#
# $sharedir::                               Override the system data directory.
#                                           type:Stdlib::Absolutepath
#
# $manage_packages::                        Should this module install packages or not.
#                                           Can also install only server packages with value
#                                           of 'server' or only agent packages with 'agent'.
#                                           type:Variant[Boolean, Enum['server', 'agent']]
#
# $package_provider::                       The provider used to install the agent.
#                                           Defaults to chocolatey on Windows
#                                           Defaults to undef elsewhere
#                                           type:Optional[String]
#
# $package_source::                         The location of the file to be used by the
#                                           agent's package resource.
#                                           Defaults to undef. If 'windows' or 'msi' are
#                                           used as the provider then this setting is
#                                           required.
#                                           type:Optional[Stdlib::Absolutepath]
#
# $port::                                   Override the port of the master we connect to.
#                                           type:Integer[0, 65535]
#
# $listen::                                 Should the puppet agent listen for connections.
#                                           type:Boolean
#
# $listen_to::                              An array of servers allowed to initiate a puppet run.
#                                           If $listen = true one of three things will happen:
#                                           1) if $listen_to is not empty then this array
#                                           will be used.
#                                           2) if $listen_to is empty and $puppetmaster is
#                                           defined then only $puppetmaster will be
#                                           allowed.
#                                           3) if $puppetmaster is not defined or empty,
#                                           $fqdn will be used.
#                                           type:Array[String]
#
# $pluginsync::                             Enable pluginsync.
#                                           type:Boolean
#
# $splay::                                  Switch to enable a random amount of time
#                                           to sleep before each run.
#                                           type:Boolean
#
# $splaylimit::                             The maximum time to delay before runs.
#                                           Defaults to being the same as the run interval.
#                                           This setting can be a time interval in seconds
#                                           (30 or 30s), minutes (30m), hours (6h), days (2d),
#                                           or years (5y).
#                                           type:Pattern[/^\d+[smhdy]?$/]
#
# $runinterval::                            Set up the interval (in seconds) to run
#                                           the puppet agent.
#                                           type:Integer[0]
#
# $autosign::                               If set to a boolean, autosign is enabled or disabled
#                                           for all incoming requests. Otherwise this has to be
#                                           set to the full file path of an autosign.conf file or
#                                           an autosign script. If this is set to a script, make
#                                           sure that script considers the content of autosign.conf
#                                           as otherwise Foreman functionality might be broken.
#                                           type:Variant[Boolean, Stdlib::Absolutepath]
#
# $autosign_entries::                       A list of certnames or domain name globs
#                                           whose certificate requests will automatically be signed.
#                                           Defaults to an empty Array.
#                                           type:Array[String]
#
# $autosign_mode::                          mode of the autosign file/script
#                                           type:Pattern[/^[0-9]{4}$/]
#
# $autosign_content::                       If set, write the autosign file content
#                                           using the value of this parameter.
#                                           Cannot be used at the same time as autosign_entries
#                                           For example, could be a string, or
#                                           file('another_module/autosign.sh') or
#                                           template('another_module/autosign.sh.erb')
#                                           type:Optional[String]
#
# $usecacheonfailure::                      Switch to enable use of cached catalog on
#                                           failure of run.
#                                           type:Boolean
#
# $runmode::                                Select the mode to setup the puppet agent.
#                                           type:Enum['cron', 'service', 'systemd.timer', 'none']
#
# $unavailable_runmodes::                   Runmodes that are not available for the
#                                           current system. This module will not try
#                                           to disable these modes. Default is []
#                                           on Linux, ['cron', 'systemd.timer'] on
#                                           Windows and ['systemd.timer'] on other
#                                           systems.
#                                           type:Array[Enum['cron', 'service', 'systemd.timer', 'none']]
#
# $cron_cmd::                               Specify command to launch when runmode is
#                                           set 'cron'.
#                                           type:Optional[String]
#
# $systemd_cmd::                            Specify command to launch when runmode is
#                                           set 'systemd.timer'.
#                                           type:Optional[String]
#
# $show_diff::                              Show and report changed files with diff output
#                                           type:Boolean
#
# $module_repository::                      Use a different puppet module repository
#                                           type:Optional[Stdlib::HTTPUrl]
#
# $configtimeout::                          How long the client should wait for the
#                                           configuration to be retrieved before
#                                           considering it a failure.
#                                           type:Optional[Integer[0]]
#
# $ca_server::                              Use a different ca server. Should be either
#                                           a string with the location of the ca_server
#                                           or 'false'.
#                                           type:Optional[Variant[String, Boolean]]
#
# $ca_port::                                Puppet CA port
#                                           type:Optional[Integer[0, 65535]]
#
# $ca_crl_filepath::                        Path to CA CRL file, dynamically resolves based on
#                                           $::server_ca status.
#                                           type:Optional[String]
#
# $dns_alt_names::                          Use additional DNS names when generating a
#                                           certificate.  Defaults to an empty Array.
#                                           type:Array[String]
#
# $classfile::                              The file in which puppet agent stores a list
#                                           of the classes associated with the retrieved
#                                           configuration.
#                                           type:String
#
# $hiera_config::                           The hiera configuration file.
#                                           type:String
#
# $syslogfacility::                         Facility name to use when logging to syslog
#                                           type:Optional[String]
#
# $auth_template::                          Use a custom template for the auth
#                                           configuration.
#                                           type:String
#
# $main_template::                          Use a custom template for the main puppet
#                                           configuration.
#                                           type:String
#
# $use_srv_records::                        Whether DNS SRV records will be used to resolve
#                                           the Puppet master
#                                           type:Boolean
#
# $srv_domain::                             Search domain for SRV records
#                                           type:String
#
# $pluginsource::                           URL to retrieve Puppet plugins from during pluginsync
#                                           type:String
#
# $pluginfactsource::                       URL to retrieve Puppet facts from during pluginsync
#                                           type:String
#
# $additional_settings::                    A hash of additional main settings.
#                                           type:Hash[String, Data]
#
# == puppet::agent parameters
#
# $agent::                                  Should a puppet agent be installed
#                                           type:Boolean
#
# $agent_noop::                             Run the agent in noop mode.
#                                           type:Boolean
#
# $agent_template::                         Use a custom template for the agent puppet
#                                           configuration.
#                                           type:String
#
# $client_package::                         Install a custom package to provide
#                                           the puppet client
#                                           type:Array[String]
#
# $puppetmaster::                           Hostname of your puppetmaster (server
#                                           directive in puppet.conf)
#                                           type:Optional[String]
#
# $prerun_command::                         A command which gets excuted before each Puppet run
#                                           type:Optional[String]
#
# $postrun_command::                        A command which gets excuted after each Puppet run
#                                           type:Optional[String]
#
# $systemd_unit_name::                      The name of the puppet systemd units.
#                                           type:String
#
# $service_name::                           The name of the puppet agent service.
#                                           type:String
#
# $agent_restart_command::                  The command which gets excuted on puppet service restart
#                                           type:Optional[String]
#
# $environment::                            Default environment of the Puppet agent
#                                           type:String
#
# $agent_additional_settings::              A hash of additional agent settings.
#                                           Example: {stringify_facts => true}
#                                           type:Hash[String, Data]
#
# $remove_lock::                            Remove the agent lock when running.
#                                           type:Boolean
#
# $client_certname::                        The node's certificate name, and the unique
#                                           identifier it uses when requesting catalogs.
#                                           type:String
#
# $dir_owner::                              Owner of the base puppet directory, used when
#                                           puppet::server is false.
#                                           type:String
#
# $dir_group::                              Group of the base puppet directory, used when
#                                           puppet::server is false.
#                                           type:Optional[String]
#
# == puppet::server parameters
#
# $server::                                 Should a puppet master be installed as well as the client
#                                           type:Boolean
#
# $server_user::                            Name of the puppetmaster user.
#                                           type:String
#
# $server_group::                           Name of the puppetmaster group.
#                                           type:String
#
# $server_dir::                             Puppet configuration directory
#                                           type:String
#
# $server_ip::                              Bind ip address of the puppetmaster
#                                           type:String
#
# $server_port::                            Puppet master port
#                                           type:Integer
#
# $server_ca::                              Provide puppet CA
#                                           type:Boolean
#
# $server_ca_crl_sync::                     Sync puppet CA crl file to compile masters, Puppet CA Must be the Puppetserver
#                                           for the compile masters. Defaults to false.
#                                           type:Boolean
#
# $server_crl_enable::                      Turn on crl checking. Defaults to true when server_ca is true. Otherwise
#                                           Defaults to false. Note unless you are using an external CA. It is recommended
#                                           to set this to true. See $server_ca_crl_sync to enable syncing from CA Puppet Master
#                                           type:Optional[Boolean]
#
# $server_http::                            Should the puppet master listen on HTTP as well as HTTPS.
#                                           Useful for load balancer or reverse proxy scenarios. Note that
#                                           the HTTP puppet master denies access from all clients by default,
#                                           allowed clients must be specified with $server_http_allow.
#                                           type:Boolean
#
# $server_http_port::                       Puppet master HTTP port; defaults to 8139.
#                                           type:Integer
#
# $server_http_allow::                      Array of allowed clients for the HTTP puppet master. Passed
#                                           to Apache's 'Allow' directive.
#                                           type:Array[String]
#
# $server_reports::                         List of report types to include on the puppetmaster
#                                           type:String
#
# $server_implementation::                  Puppet master implementation, either "master" (traditional
#                                           Ruby) or "puppetserver" (JVM-based)
#                                           type:Enum['master', 'puppetserver']
#
# $server_passenger::                       If set to true, we will configure apache with
#                                           passenger. If set to false, we will enable the
#                                           default puppetmaster service unless
#                                           service_fallback is set to false. See 'Advanced
#                                           server parameters' for more information.
#                                           Only applicable when server_implementation is "master".
#                                           type:Boolean
#
# $server_external_nodes::                  External nodes classifier executable
#                                           type:Stdlib::Absolutepath
#
# $server_template::                        Which template should be used for master
#                                           configuration
#                                           type:String
#
# $server_main_template::                   Which template should be used for master
#                                           related configuration in the [main] section
#                                           type:String
#
# $server_git_repo::                        Use git repository as a source of modules
#                                           type:Boolean
#
# $server_dynamic_environments::            Use $environment in the modulepath
#                                           Deprecated when $server_directory_environments is true,
#                                           set $server_environments to [] instead.
#                                           type:Boolean
#
# $server_directory_environments::          Enable directory environments, defaulting to true
#                                           with Puppet 3.6.0 or higher
#                                           type:Boolean
#
# $server_environments::                    Environments to setup (creates directories).
#                                           Applies only when $server_dynamic_environments
#                                           is false
#                                           type:Array[String]
#
# $server_environments_owner::              The owner of the environments directory
#                                           type:String
#
# $server_environments_group::              The group owning the environments directory
#                                           type:Optional[String]
#
# $server_environments_mode::               Environments directory mode.
#                                           type:Pattern[/^[0-9]{4}$/]
#
# $server_envs_dir::                        Directory that holds puppet environments
#                                           type:Stdlib::Absolutepath
#
# $server_envs_target::                     Indicates that $envs_dir should be
#                                           a symbolic link to this target
#                                           type:Optional[Stdlib::Absolutepath]
#
# $server_common_modules_path::             Common modules paths (only when
#                                           $server_git_repo_path and $server_dynamic_environments
#                                           are false)
#                                           type:Array[Stdlib::Absolutepath]
#
# $server_git_repo_path::                   Git repository path
#                                           type:Stdlib::Absolutepath
#
# $server_git_repo_mode::                   Git repository mode
#                                           type:Pattern[/^[0-9]{4}$/]
#
# $server_git_repo_group::                  Git repository group
#                                           type:String
#
# $server_git_repo_user::                   Git repository user
#                                           type:String
#
# $server_git_branch_map::                  Git branch to puppet env mapping for the
#                                           default post receive hook
#                                           type:Hash[String, String]
#
# $server_post_hook_content::               Which template to use for git post hook
#                                           type:String
#
# $server_post_hook_name::                  Name of a git hook
#                                           type:String
#
# $server_storeconfigs_backend::            Do you use storeconfigs? (note: not required)
#                                           false if you don't, "active_record" for 2.X
#                                           style db, "puppetdb" for puppetdb
#                                           type:Variant[Undef, Boolean, Enum['active_record', 'puppetdb']]
#
# $server_app_root::                        Directory where the application lives
#                                           type:Stdlib::Absolutepath
#
# $server_ssl_dir::                         SSL directory
#                                           type:Stdlib::Absolutepath
#
# $server_package::                         Custom package name for puppet master
#                                           type:Optional[String]
#
# $server_version::                         Custom package version for puppet master
#                                           type:Optional[String]
#
# $server_certname::                        The name to use when handling certificates.
#                                           type:String
#
# $server_strict_variables::                if set to true, it will throw parse errors
#                                           when accessing undeclared variables.
#                                           type:Boolean
#
# $server_additional_settings::             A hash of additional settings.
#                                           Example: {trusted_node_data => true, ordering => 'manifest'}
#                                           type:Hash[String, Data]
#
# $server_rack_arguments::                  Arguments passed to rack app ARGV in addition to --confdir and
#                                           --vardir.  The default is an empty array.
#                                           type:Array[String]
#
# $server_puppetdb_host::                   PuppetDB host
#                                           type:Optional[String]
#
# $server_puppetdb_port::                   PuppetDB port
#                                           type:Integer[0, 65535]
#
# $server_puppetdb_swf::                    PuppetDB soft_write_failure
#                                           type:Boolean
#
# $server_parser::                          Sets the parser to use. Valid options are 'current' or 'future'.
#                                           Defaults to 'current'.
#                                           type:Enum['current', 'future']
#
# === Advanced server parameters:
#
# $server_httpd_service::                   Apache/httpd service name to notify
#                                           on configuration changes. Defaults
#                                           to 'httpd' based on the default
#                                           apache module included with foreman-installer.
#                                           type:String
#
# $server_service_fallback::                If passenger is not used, do we want to fallback
#                                           to using the puppetmaster service? Set to false
#                                           if you disabled passenger and you do NOT want to
#                                           use the puppetmaster service. Defaults to true.
#                                           type:Boolean
#
# $server_passenger_min_instances::         The PassengerMinInstances parameter. Sets the
#                                           minimum number of application processes to run.
#                                           Defaults to the number of processors on your
#                                           system.
#                                           type:Integer[0]
#
# $server_passenger_pre_start::             Pre-start the first passenger worker instance
#                                           process during httpd start.
#                                           type:Boolean
#
# $server_passenger_ruby::                  The PassengerRuby parameter. Sets the Ruby
#                                           interpreter for serving the puppetmaster
#                                           rack application.
#                                           type:Optional[String]
#
# $server_config_version::                  How to determine the configuration version. When
#                                           using git_repo, by default a git describe
#                                           approach will be installed.
#                                           type:Optional[String]
#
# $server_foreman_facts::                   Should foreman receive facts from puppet
#                                           type:Boolean
#
# $server_foreman::                         Should foreman integration be installed
#                                           type:Boolean
#
# $server_foreman_url::                     Foreman URL
#                                           type:Stdlib::HTTPUrl
#
# $server_foreman_ssl_ca::                  SSL CA of the Foreman server
#                                           type:Optional[Stdlib::Absolutepath]
#
# $server_foreman_ssl_cert::                Client certificate for authenticating against Foreman server
#                                           type:Optional[Stdlib::Absolutepath]
#
# $server_foreman_ssl_key::                 Key for authenticating against Foreman server
#                                           type:Optional[Stdlib::Absolutepath]
#
# $server_puppet_basedir::                  Where is the puppet code base located
#                                           type:Optional[Stdlib::Absolutepath]
#
# $server_enc_api::                         What version of enc script to deploy. Valid
#                                           values are 'v2' for latest, and 'v1'
#                                           for Foreman =< 1.2
#                                           type:Enum['v2', 'v1']
#
# $server_report_api::                      What version of report processor to deploy.
#                                           Valid values are 'v2' for latest, and 'v1'
#                                           for Foreman =< 1.2
#                                           type:Enum['v2', 'v1']
#
# $server_request_timeout::                 Timeout in node.rb script for fetching
#                                           catalog from Foreman (in seconds).
#                                           type:Integer[0]
#
# $server_environment_timeout::             Timeout for cached compiled catalogs (10s, 5m, ...)
#                                           type:Variant[Undef, Enum['unlimited'], Pattern[/^\d+[smhdy]?$/]]
#
# $server_ca_proxy::                        The actual server that handles puppet CA.
#                                           Setting this to anything non-empty causes
#                                           the apache vhost to set up a proxy for all
#                                           certificates pointing to the value.
#                                           type:Optional[String]
#
# $server_jvm_java_bin::                    Set the default java to use.
#                                           type:String
#
# $server_jvm_config::                      Specify the puppetserver jvm configuration file.
#                                           type:String
#
# $server_jvm_min_heap_size::               Specify the minimum jvm heap space.
#                                           type:String
#
# $server_jvm_max_heap_size::               Specify the maximum jvm heap space.
#                                           type:String
#
# $server_jvm_extra_args::                  Additional java options to pass through.
#                                           This can be used for Java versions prior to
#                                           Java 8 to specify the max perm space to use:
#                                           For example: '-XX:MaxPermSpace=128m'.
#                                           type:String
#
# $server_jruby_gem_home::                  Where jruby gems are located for puppetserver
#                                           type:String
#
# $allow_any_crl_auth::                     Allow any authentication for the CRL. This
#                                           is needed on the puppet CA to accept clients
#                                           from a the puppet CA proxy.
#                                           type:Boolean
#
# $auth_allowed::                           An array of authenticated nodes allowed to
#                                           access all catalog and node endpoints.
#                                           default to ['$1']
#                                           type:Array[String]
#
# $server_default_manifest::                Toggle if default_manifest setting should
#                                           be added to the [main] section
#                                           type:Boolean
#
# $server_default_manifest_path::           A string setting the path to the default_manifest
#                                           type:Stdlib::Absolutepath
#
# $server_default_manifest_content::        A string to set the content of the default_manifest
#                                           If set to '' it will not manage the file
#                                           type:String
#
# $server_ssl_dir_manage::                  Toggle if ssl_dir should be added to the [master]
#                                           configuration section. This is necessary to
#                                           disable in case CA is delegated to a separate instance
#                                           type:Boolean
#
# $server_puppetserver_vardir::             The path of the puppetserver var dir
#                                           type:Stdlib::Absolutepath
#
# $server_puppetserver_rundir::             The path of the puppetserver run dir
#                                           type:Optional[Stdlib::Absolutepath]
#
# $server_puppetserver_logdir::             The path of the puppetserver log dir
#                                           type:Optional[Stdlib::Absolutepath]
#
# $server_puppetserver_dir::                The path of the puppetserver config dir
#                                           type:Stdlib::Absolutepath
#
# $server_puppetserver_version::            The version of puppetserver 2 installed (or being installed)
#                                           Unfortunately, different versions of puppetserver need configuring differently,
#                                           and there's no easy way of determining which version is being installed.
#                                           Defaults to '2.3.1' but can be overriden if you're installing an older version.
#                                           type:Pattern[/^[0-9\.]+$/]
#
# $server_max_active_instances::            Max number of active jruby instances. Defaults to
#                                           processor count
#                                           type:Integer[1]
#
# $server_max_requests_per_instance::       Max number of requests a jruby instances will handle. Defaults to 0 (disabled)
#                                           type:Integer[0]
#
# $server_idle_timeout::                    How long the server will wait for a response on an existing connection
#                                           type:Integer[0]
#
# $server_connect_timeout::                 How long the server will wait for a response to a connection attempt
#                                           type:Integer[0]
#
# $server_ssl_protocols::                   Array of SSL protocols to use.
#                                           Defaults to [ 'TLSv1.2' ]
#                                           type:Array[String]
#
# $server_cipher_suites::                   List of SSL ciphers to use in negotiation
#                                           Defaults to [ 'TLS_RSA_WITH_AES_256_CBC_SHA256', 'TLS_RSA_WITH_AES_256_CBC_SHA',
#                                           'TLS_RSA_WITH_AES_128_CBC_SHA256', 'TLS_RSA_WITH_AES_128_CBC_SHA', ]
#                                           type:Array[String]
#
# $server_ruby_load_paths::                 List of ruby paths
#                                           Defaults based on $::puppetversion
#                                           type:Array[Stdlib::Absolutepath]
#
# $server_ca_client_whitelist::             The whitelist of client certificates that
#                                           can query the certificate-status endpoint
#                                           Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#                                           type:Array[String]
#
# $server_admin_api_whitelist::             The whitelist of clients that
#                                           can query the puppet-admin-api endpoint
#                                           Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#                                           type:Array[String]
#
# $server_enable_ruby_profiler::            Should the puppetserver ruby profiler be enabled?
#                                           Defaults to false
#                                           type:Boolean
#
# $server_ca_auth_required::                Whether client certificates are needed to access the puppet-admin api
#                                           Defaults to true
#                                           type:Boolean
#
# $server_use_legacy_auth_conf::            Should the puppetserver use the legacy puppet auth.conf?
#                                           Defaults to false (the puppetserver will use its own conf.d/auth.conf)
#                                           type:Boolean
#
# $server_check_for_updates::               Should the puppetserver phone home to check for available updates?
#                                           Defaults to true
#                                           type:Boolean
#
# $server_environment_class_cache_enabled:: Enable environment class cache in conjunction with the use of the
#                                           environment_classes API.
#                                           Defaults to false
#                                           type:Boolean
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
  $version                                = $puppet::params::version,
  $user                                   = $puppet::params::user,
  $group                                  = $puppet::params::group,
  $dir                                    = $puppet::params::dir,
  $codedir                                = $puppet::params::codedir,
  $vardir                                 = $puppet::params::vardir,
  $logdir                                 = $puppet::params::logdir,
  $rundir                                 = $puppet::params::rundir,
  $ssldir                                 = $puppet::params::ssldir,
  $sharedir                               = $puppet::params::sharedir,
  $manage_packages                        = $puppet::params::manage_packages,
  $dir_owner                              = $puppet::params::dir_owner,
  $dir_group                              = $puppet::params::dir_group,
  $package_provider                       = $puppet::params::package_provider,
  $package_source                         = $puppet::params::package_source,
  $port                                   = $puppet::params::port,
  $listen                                 = $puppet::params::listen,
  $listen_to                              = $puppet::params::listen_to,
  $pluginsync                             = $puppet::params::pluginsync,
  $splay                                  = $puppet::params::splay,
  $splaylimit                             = $puppet::params::splaylimit,
  $autosign                               = $puppet::params::autosign,
  $autosign_entries                       = $puppet::params::autosign_entries,
  $autosign_mode                          = $puppet::params::autosign_mode,
  $autosign_content                       = $puppet::params::autosign_content,
  $runinterval                            = $puppet::params::runinterval,
  $usecacheonfailure                      = $puppet::params::usecacheonfailure,
  $runmode                                = $puppet::params::runmode,
  $unavailable_runmodes                   = $puppet::params::unavailable_runmodes,
  $cron_cmd                               = $puppet::params::cron_cmd,
  $systemd_cmd                            = $puppet::params::systemd_cmd,
  $agent_noop                             = $puppet::params::agent_noop,
  $show_diff                              = $puppet::params::show_diff,
  $module_repository                      = $puppet::params::module_repository,
  $configtimeout                          = $puppet::params::configtimeout,
  $ca_server                              = $puppet::params::ca_server,
  $ca_port                                = $puppet::params::ca_port,
  $ca_crl_filepath                        = $puppet::params::ca_crl_filepath,
  $prerun_command                         = $puppet::params::prerun_command,
  $postrun_command                        = $puppet::params::postrun_command,
  $dns_alt_names                          = $puppet::params::dns_alt_names,
  $use_srv_records                        = $puppet::params::use_srv_records,
  $srv_domain                             = $puppet::params::srv_domain,
  $pluginsource                           = $puppet::params::pluginsource,
  $pluginfactsource                       = $puppet::params::pluginfactsource,
  $additional_settings                    = $puppet::params::additional_settings,
  $agent_additional_settings              = $puppet::params::agent_additional_settings,
  $agent_restart_command                  = $puppet::params::agent_restart_command,
  $classfile                              = $puppet::params::classfile,
  $hiera_config                           = $puppet::params::hiera_config,
  $main_template                          = $puppet::params::main_template,
  $agent_template                         = $puppet::params::agent_template,
  $auth_template                          = $puppet::params::auth_template,
  $allow_any_crl_auth                     = $puppet::params::allow_any_crl_auth,
  $auth_allowed                           = $puppet::params::auth_allowed,
  $client_package                         = $puppet::params::client_package,
  $agent                                  = $puppet::params::agent,
  $remove_lock                            = $puppet::params::remove_lock,
  $client_certname                        = $puppet::params::client_certname,
  $puppetmaster                           = $puppet::params::puppetmaster,
  $systemd_unit_name                      = $puppet::params::systemd_unit_name,
  $service_name                           = $puppet::params::service_name,
  $syslogfacility                         = $puppet::params::syslogfacility,
  $environment                            = $puppet::params::environment,
  $server                                 = $puppet::params::server,
  $server_admin_api_whitelist             = $puppet::params::server_admin_api_whitelist,
  $server_user                            = $puppet::params::user,
  $server_group                           = $puppet::params::group,
  $server_dir                             = $puppet::params::dir,
  $server_ip                              = $puppet::params::ip,
  $server_port                            = $puppet::params::port,
  $server_ca                              = $puppet::params::server_ca,
  $server_ca_crl_sync                     = $puppet::params::server_ca_crl_sync,
  $server_crl_enable                      = $puppet::params::server_crl_enable,
  $server_ca_auth_required                = $puppet::params::server_ca_auth_required,
  $server_ca_client_whitelist             = $puppet::params::server_ca_client_whitelist,
  $server_http                            = $puppet::params::server_http,
  $server_http_port                       = $puppet::params::server_http_port,
  $server_http_allow                      = $puppet::params::server_http_allow,
  $server_reports                         = $puppet::params::server_reports,
  $server_implementation                  = $puppet::params::server_implementation,
  $server_passenger                       = $puppet::params::server_passenger,
  $server_puppetserver_dir                = $puppet::params::server_puppetserver_dir,
  $server_puppetserver_vardir             = $puppet::params::server_puppetserver_vardir,
  $server_puppetserver_rundir             = $puppet::params::server_puppetserver_rundir,
  $server_puppetserver_logdir             = $puppet::params::server_puppetserver_logdir,
  $server_puppetserver_version            = $puppet::params::server_puppetserver_version,
  $server_service_fallback                = $puppet::params::server_service_fallback,
  $server_passenger_min_instances         = $puppet::params::server_passenger_min_instances,
  $server_passenger_pre_start             = $puppet::params::server_passenger_pre_start,
  $server_passenger_ruby                  = $puppet::params::server_passenger_ruby,
  $server_httpd_service                   = $puppet::params::server_httpd_service,
  $server_external_nodes                  = $puppet::params::server_external_nodes,
  $server_template                        = $puppet::params::server_template,
  $server_main_template                   = $puppet::params::server_main_template,
  $server_cipher_suites                   = $puppet::params::server_cipher_suites,
  $server_config_version                  = $puppet::params::server_config_version,
  $server_connect_timeout                 = $puppet::params::server_connect_timeout,
  $server_git_repo                        = $puppet::params::server_git_repo,
  $server_dynamic_environments            = $puppet::params::server_dynamic_environments,
  $server_directory_environments          = $puppet::params::server_directory_environments,
  $server_default_manifest                = $puppet::params::server_default_manifest,
  $server_default_manifest_path           = $puppet::params::server_default_manifest_path,
  $server_default_manifest_content        = $puppet::params::server_default_manifest_content,
  $server_enable_ruby_profiler            = $puppet::params::server_enable_ruby_profiler,
  $server_environments                    = $puppet::params::server_environments,
  $server_environments_owner              = $puppet::params::server_environments_owner,
  $server_environments_group              = $puppet::params::server_environments_group,
  $server_environments_mode               = $puppet::params::server_environments_mode,
  $server_envs_dir                        = $puppet::params::server_envs_dir,
  $server_envs_target                     = $puppet::params::server_envs_target,
  $server_common_modules_path             = $puppet::params::server_common_modules_path,
  $server_git_repo_mode                   = $puppet::params::server_git_repo_mode,
  $server_git_repo_path                   = $puppet::params::server_git_repo_path,
  $server_git_repo_group                  = $puppet::params::server_git_repo_group,
  $server_git_repo_user                   = $puppet::params::server_git_repo_user,
  $server_git_branch_map                  = $puppet::params::server_git_branch_map,
  $server_idle_timeout                    = $puppet::params::server_idle_timeout,
  $server_post_hook_content               = $puppet::params::server_post_hook_content,
  $server_post_hook_name                  = $puppet::params::server_post_hook_name,
  $server_storeconfigs_backend            = $puppet::params::server_storeconfigs_backend,
  $server_app_root                        = $puppet::params::server_app_root,
  $server_ruby_load_paths                 = $puppet::params::server_ruby_load_paths,
  $server_ssl_dir                         = $puppet::params::server_ssl_dir,
  $server_ssl_dir_manage                  = $puppet::params::server_ssl_dir_manage,
  $server_ssl_protocols                   = $puppet::params::server_ssl_protocols,
  $server_package                         = $puppet::params::server_package,
  $server_version                         = $puppet::params::server_version,
  $server_certname                        = $puppet::params::server_certname,
  $server_enc_api                         = $puppet::params::server_enc_api,
  $server_report_api                      = $puppet::params::server_report_api,
  $server_request_timeout                 = $puppet::params::server_request_timeout,
  $server_ca_proxy                        = $puppet::params::server_ca_proxy,
  $server_strict_variables                = $puppet::params::server_strict_variables,
  $server_additional_settings             = $puppet::params::server_additional_settings,
  $server_rack_arguments                  = $puppet::params::server_rack_arguments,
  $server_foreman                         = $puppet::params::server_foreman,
  $server_foreman_url                     = $puppet::params::server_foreman_url,
  $server_foreman_ssl_ca                  = $puppet::params::server_foreman_ssl_ca,
  $server_foreman_ssl_cert                = $puppet::params::server_foreman_ssl_cert,
  $server_foreman_ssl_key                 = $puppet::params::server_foreman_ssl_key,
  $server_foreman_facts                   = $puppet::params::server_foreman_facts,
  $server_puppet_basedir                  = $puppet::params::server_puppet_basedir,
  $server_puppetdb_host                   = $puppet::params::server_puppetdb_host,
  $server_puppetdb_port                   = $puppet::params::server_puppetdb_port,
  $server_puppetdb_swf                    = $puppet::params::server_puppetdb_swf,
  $server_parser                          = $puppet::params::server_parser,
  $server_environment_timeout             = $puppet::params::server_environment_timeout,
  $server_jvm_java_bin                    = $puppet::params::server_jvm_java_bin,
  $server_jvm_config                      = $puppet::params::server_jvm_config,
  $server_jvm_min_heap_size               = $puppet::params::server_jvm_min_heap_size,
  $server_jvm_max_heap_size               = $puppet::params::server_jvm_max_heap_size,
  $server_jvm_extra_args                  = $puppet::params::server_jvm_extra_args,
  $server_jruby_gem_home                  = $puppet::params::server_jruby_gem_home,
  $server_max_active_instances            = $puppet::params::server_max_active_instances,
  $server_max_requests_per_instance       = $puppet::params::server_max_requests_per_instance,
  $server_use_legacy_auth_conf            = $puppet::params::server_use_legacy_auth_conf,
  $server_check_for_updates               = $puppet::params::server_check_for_updates,
  $server_environment_class_cache_enabled = $puppet::params::server_environment_class_cache_enabled,
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

  # Ensure the server is running before the agent needs it, and that
  # certificates are generated in the server config (if enabled)
  if $server == true and $agent == true {
    Class['puppet::server'] -> Class['puppet::agent::service']
  }
}
