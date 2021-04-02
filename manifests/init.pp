# == Class: puppet
#
# This class installs and configures the puppet agent.
#
# === Parameters:
#
# $show_diff::                              Show and report changed files with diff output
#
# $ca_server::                              Use a different ca server. Should be either
#                                           a string with the location of the ca_server
#                                           or 'false'.
#
# == Advanced puppet parameters
#
# $version::                                Specify a specific version of a package to
#                                           install. The version should be the exact
#                                           match for your distro.
#                                           You can also use certain values like 'latest'.
#                                           Note that when you specify exact versions you
#                                           should also override $server_version since
#                                           that defaults to $version.
#
# $manage_packages::                        Should this module install packages or not.
#                                           Can also install only server packages with value
#                                           of 'server' or only agent packages with 'agent'.
#
# $port::                                   Override the port of the master we connect to.
#
# $pluginsync::                             Enable pluginsync.
#
# $splay::                                  Switch to enable a random amount of time
#                                           to sleep before each run.
#
# $splaylimit::                             The maximum time to delay before runs.
#                                           Defaults to being the same as the run interval.
#                                           This setting can be a time interval in seconds
#                                           (30 or 30s), minutes (30m), hours (6h), days (2d),
#                                           or years (5y).
#
# $runinterval::                            Set up the interval (in seconds) to run
#                                           the puppet agent.
#
# $autosign::                               If set to a boolean, autosign is enabled or disabled
#                                           for all incoming requests. Otherwise this has to be
#                                           set to the full file path of an autosign.conf file or
#                                           an autosign script. If this is set to a script, make
#                                           sure that script considers the content of autosign.conf
#                                           as otherwise Foreman functionality might be broken.
#
# $autosign_entries::                       A list of certnames or domain name globs
#                                           whose certificate requests will automatically be signed.
#                                           Defaults to an empty Array.
#
# $autosign_mode::                          mode of the autosign file/script
#
# $autosign_content::                       If set, write the autosign file content
#                                           using the value of this parameter.
#                                           Cannot be used at the same time as autosign_entries
#                                           For example, could be a string, or
#                                           file('another_module/autosign.sh') or
#                                           template('another_module/autosign.sh.erb')
#
# $autosign_source::                        If set, use this as the source for the autosign file,
#                                           instead of autosign_content.
#
# $usecacheonfailure::                      Switch to enable use of cached catalog on
#                                           failure of run.
#
# $runmode::                                Select the mode to setup the puppet agent.
#
# $run_hour::                               The hour at which to run the puppet agent
#                                           when runmode is cron or systemd.timer.
#
# $run_minute::                             The minute at which to run the puppet agent
#                                           when runmode is cron or systemd.timer.
#
# $cron_cmd::                               Specify command to launch when runmode is
#                                           set 'cron'.
#
# $systemd_cmd::                            Specify command to launch when runmode is
#                                           set 'systemd.timer'.
#
# $systemd_randomizeddelaysec::             Adds a random delay between 0 and this value
#                                           (in seconds) to the timer. Only relevant when
#                                           runmode is 'systemd.timer'.
#
# $module_repository::                      Use a different puppet module repository
#
# $ca_port::                                Puppet CA port
#
# $ca_crl_filepath::                        Path to CA CRL file, dynamically resolves based on
#                                           $::server_ca status.
#
# $dns_alt_names::                          Use additional DNS names when generating a
#                                           certificate.  Defaults to an empty Array.
#
# $hiera_config::                           The hiera configuration file.
#
# $syslogfacility::                         Facility name to use when logging to syslog
#
# $use_srv_records::                        Whether DNS SRV records will be used to resolve
#                                           the Puppet master
#
# $srv_domain::                             Search domain for SRV records
#
# $additional_settings::                    A hash of additional main settings.
#
# $http_connect_timeout::                   The maximum amount of time an agent waits
#                                           when establishing an HTTP connection.
#
# $http_read_timeout::                      The time an agent waits for one block to be
#                                           read from an HTTP connection. If nothing is
#                                           read after the elapsed interval then the
#                                           connection will be closed.
#
# $user::                                   Override the name of the puppet user.
#
# $group::                                  Override the name of the puppet group.
#
# $dir::                                    Override the puppet directory.
#
# $codedir::                                Override the puppet code directory.
#
# $vardir::                                 Override the puppet var directory.
#
# $logdir::                                 Override the log directory.
#
# $rundir::                                 Override the PID directory.
#
# $ssldir::                                 Override where SSL certificates are kept.
#
# $sharedir::                               Override the system data directory.
#
# $package_provider::                       The provider used to install the agent.
#                                           Defaults to chocolatey on Windows
#                                           Defaults to undef elsewhere
#
# $package_source::                         The location of the file to be used by the
#                                           agent's package resource.
#                                           Defaults to undef. If 'windows' or 'msi' are
#                                           used as the provider then this setting is
#                                           required.
# $package_install_options::                Flags that should be passed to the package manager
#                                           during installation. Defaults to undef. May be
#                                           a string or a hash, see Puppet Package resource
#                                           documentation for the provider matching your package manager
#
# $unavailable_runmodes::                   Runmodes that are not available for the
#                                           current system. This module will not try
#                                           to disable these modes. Default is []
#                                           on Linux, ['cron', 'systemd.timer'] on
#                                           Windows and ['systemd.timer'] on other
#                                           systems.
#
# $auth_template::                          Use a custom template for /etc/puppetlabs/puppet/auth.conf
#
# $pluginsource::                           URL to retrieve Puppet plugins from during pluginsync
#
# $pluginfactsource::                       URL to retrieve Puppet facts from during pluginsync
#
# $classfile::                              The file in which puppet agent stores a list
#                                           of the classes associated with the retrieved
#                                           configuration.
#
# == puppet::agent parameters
#
# $agent::                                  Should a puppet agent be installed
#
# $agent_noop::                             Run the agent in noop mode.
#
# $puppetmaster::                           Hostname of your puppetmaster (server
#                                           directive in puppet.conf)
#
# $prerun_command::                         A command which gets excuted before each Puppet run
#
# $postrun_command::                        A command which gets excuted after each Puppet run
#
# $environment::                            Default environment of the Puppet agent
#
# $agent_additional_settings::              A hash of additional agent settings.
#                                           Example: {stringify_facts => true}
#
# $client_certname::                        The node's certificate name, and the unique
#                                           identifier it uses when requesting catalogs.
#
# $report::                                 Send reports to the Puppet Master
#
# == advanced agent parameters
#
# $service_name::                           The name of the puppet agent service.
#
# $agent_restart_command::                  The command which gets excuted on puppet service restart
#
# $client_package::                         Install a custom package to provide
#                                           the puppet client
#
# $systemd_unit_name::                      The name of the puppet systemd units.
#
# $remove_lock::                            Remove the agent lock when running.
#
# $dir_owner::                              Owner of the base puppet directory, used when
#                                           puppet::server is false.
#
# $dir_group::                              Group of the base puppet directory, used when
#                                           puppet::server is false.
#
# == puppet::server parameters
#
# $server::                                 Should a puppet master be installed as well as the client
#
# $server_ip::                              Bind ip address of the puppetmaster
#
# $server_port::                            Puppet master port
#
# $server_ca::                              Provide puppet CA
#
# $server_ca_crl_sync::                     Sync puppet CA crl file to compile masters, Puppet CA Must be the Puppetserver
#                                           for the compile masters. Defaults to false.
#
# $server_crl_enable::                      Turn on crl checking. Defaults to true when server_ca is true. Otherwise
#                                           Defaults to false. Note unless you are using an external CA. It is recommended
#                                           to set this to true. See $server_ca_crl_sync to enable syncing from CA Puppet Master
#
# $server_reports::                         List of report types to include on the puppetmaster
#
# $server_external_nodes::                  External nodes classifier executable
#
# $server_trusted_external_command::        The external trusted facts script to use.
#                                           (Puppet >= 6.11 only).
#
# $server_git_repo::                        Use git repository as a source of modules
#
# $server_environments_owner::              The owner of the environments directory
#
# $server_environments_group::              The group owning the environments directory
#
# $server_environments_mode::               Environments directory mode.
#
# $server_common_modules_path::             Common modules paths
#
# $server_git_repo_path::                   Git repository path
#
# $server_git_repo_mode::                   Git repository mode
#
# $server_git_repo_group::                  Git repository group
#
# $server_git_repo_user::                   Git repository user
#
# $server_git_branch_map::                  Git branch to puppet env mapping for the
#                                           default post receive hook
#
# $server_storeconfigs::                    Whether to enable storeconfigs
#
# $server_certname::                        The name to use when handling certificates.
#
# === Advanced server parameters:
#
# $server_strict_variables::                if set to true, it will throw parse errors
#                                           when accessing undeclared variables.
#
# $server_additional_settings::             A hash of additional settings.
#                                           Example: {trusted_node_data => true, ordering => 'manifest'}
#
# $server_manage_user::                     Whether to manage the server user resource
#
# $server_user::                            Name of the puppetmaster user.
#
# $server_group::                           Name of the puppetmaster group.
#
# $server_dir::                             Puppet configuration directory
#
# $server_http::                            Should the puppet master listen on HTTP as well as HTTPS.
#                                           Useful for load balancer or reverse proxy scenarios.
#
# $server_http_port::                       Puppet master HTTP port; defaults to 8139.
#
# $server_config_version::                  How to determine the configuration version. When
#                                           using git_repo, by default a git describe
#                                           approach will be installed.
#
# $server_foreman_facts::                   Should foreman receive facts from puppet
#
# $server_foreman::                         Should foreman integration be installed
#
# $server_foreman_url::                     Foreman URL
#
# $server_foreman_ssl_ca::                  SSL CA of the Foreman server
#
# $server_foreman_ssl_cert::                Client certificate for authenticating against Foreman server
#
# $server_foreman_ssl_key::                 Key for authenticating against Foreman server
#
# $server_puppet_basedir::                  Where is the puppet code base located
#
# $server_request_timeout::                 Timeout in node.rb script for fetching
#                                           catalog from Foreman (in seconds).
#
# $server_environment_timeout::             Timeout for cached compiled catalogs (10s, 5m, ...)
#
# $server_envs_dir::                        Directory that holds puppet environments
#
# $server_envs_target::                     Indicates that $envs_dir should be
#                                           a symbolic link to this target
#
# $server_jvm_java_bin::                    Set the default java to use.
#
# $server_jvm_config::                      Specify the puppetserver jvm configuration file.
#
# $server_jvm_min_heap_size::               Specify the minimum jvm heap space.
#
# $server_jvm_max_heap_size::               Specify the maximum jvm heap space.
#
# $server_jvm_extra_args::                  Additional java options to pass through.
#                                           This can be used for Java versions prior to
#                                           Java 8 to specify the max perm space to use:
#                                           For example: '-XX:MaxPermSize=128m'.
#
# $server_jvm_cli_args::                    Java options to use when using puppetserver
#                                           subcommands (eg puppetserver gem).
#
# $server_jruby_gem_home::                  Where jruby gems are located for puppetserver
#
# $allow_any_crl_auth::                     Allow any authentication for the CRL. This
#                                           is needed on the puppet CA to accept clients
#                                           from a the puppet CA proxy.
#
# $auth_allowed::                           An array of authenticated nodes allowed to
#                                           access all catalog and node endpoints.
#                                           default to ['$1']
#
# $server_default_manifest::                Toggle if default_manifest setting should
#                                           be added to the [main] section
#
# $server_default_manifest_path::           A string setting the path to the default_manifest
#
# $server_default_manifest_content::        A string to set the content of the default_manifest
#                                           If set to '' it will not manage the file
#
# $server_package::                         Custom package name for puppet master
#
# $server_version::                         Custom package version for puppet master
#
# $server_ssl_dir::                         SSL directory
#
# $server_ssl_dir_manage::                  Toggle if ssl_dir should be added to the [master]
#                                           configuration section. This is necessary to
#                                           disable in case CA is delegated to a separate instance
#
# $server_ssl_key_manage::                  Toggle if "private_keys/${::puppet::server::certname}.pem"
#                                           should be created with default user and group. This is used in
#                                           the default Forman setup to reuse the key for TLS communication.
#
# $server_puppetserver_vardir::             The path of the puppetserver var dir
#
# $server_puppetserver_rundir::             The path of the puppetserver run dir
#
# $server_puppetserver_logdir::             The path of the puppetserver log dir
#
# $server_puppetserver_dir::                The path of the puppetserver config dir
#
# $server_puppetserver_version::            The version of puppetserver installed (or being installed)
#                                           Unfortunately, different versions of puppetserver need
#                                           configuring differently. The default is derived from the
#                                           installed puppet version. Generally it's not needed to
#                                           override this but when upgrading it might be.
#
# $server_max_active_instances::            Max number of active jruby instances. Defaults to
#                                           processor count
#
# $server_max_requests_per_instance::       Max number of requests a jruby instances will handle. Defaults to 0 (disabled)
#
# $server_max_queued_requests::             The maximum number of requests that may be queued waiting to borrow a
#                                           JRuby from the pool. (Puppetserver 5.x only)
#                                           Defaults to 0 (disabled) for Puppetserver >= 5.0
#
# $server_max_retry_delay::                 Sets the upper limit for the random sleep set as a Retry-After header on
#                                           503 responses returned when max-queued-requests is enabled. (Puppetserver 5.x only)
#                                           Defaults to 1800 for Puppetserver >= 5.0
#
# $server_multithreaded::                   Use multithreaded jruby. (Puppetserver >= 6.8 only).  Defaults to false.
#
# $server_idle_timeout::                    How long the server will wait for a response on an existing connection
#
# $server_connect_timeout::                 How long the server will wait for a response to a connection attempt
#
# $server_ssl_protocols::                   Array of SSL protocols to use.
#                                           Defaults to [ 'TLSv1.2' ]
#
# $server_ssl_chain_filepath::              Path to certificate chain for puppetserver
#                                           Only used when $ca is true
#                                           Defaults to "${ssl_dir}/ca/ca_crt.pem"
#
# $server_cipher_suites::                   List of SSL ciphers to use in negotiation
#                                           Defaults to [ 'TLS_RSA_WITH_AES_256_CBC_SHA256', 'TLS_RSA_WITH_AES_256_CBC_SHA',
#                                           'TLS_RSA_WITH_AES_128_CBC_SHA256', 'TLS_RSA_WITH_AES_128_CBC_SHA', ]
#
# $server_ruby_load_paths::                 List of ruby paths
#                                           Defaults based on $::puppetversion
#
# $server_ca_client_whitelist::             The whitelist of client certificates that
#                                           can query the certificate-status endpoint
#                                           Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#
# $server_custom_trusted_oid_mapping::      A hash of custom trusted oid mappings. Defaults to undef
#                                           Example: { 1.3.6.1.4.1.34380.1.2.1.1 => { shortname => 'myshortname' } }
#
# $server_admin_api_whitelist::             The whitelist of clients that
#                                           can query the puppet-admin-api endpoint
#                                           Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#
# $server_ca_auth_required::                Whether client certificates are needed to access the puppet-admin api
#                                           Defaults to true
#
# $server_ca_client_self_delete::           Adds a rule to auth.conf, that allows a client to delete its own certificate
#                                           Defaults to false
#
# $server_use_legacy_auth_conf::            Should the puppetserver use the legacy puppet auth.conf?
#                                           Defaults to false (the puppetserver will use its own conf.d/auth.conf)
#
# $server_check_for_updates::               Should the puppetserver phone home to check for available updates?
#                                           Defaults to true
#
# $server_post_hook_content::               Which template to use for git post hook
#
# $server_post_hook_name::                  Name of a git hook
#
# $server_environment_class_cache_enabled:: Enable environment class cache in conjunction with the use of the
#                                           environment_classes API.
#                                           Defaults to false
#
# $server_allow_header_cert_info::          Enable client authentication over HTTP Headers
#                                           Defaults to false, is also activated by the $server_http setting
#
# $server_web_idle_timeout::                Time in ms that Jetty allows a socket to be idle, after processing has
#                                           completed.
#                                           Defaults to 30000, using the Jetty default of 30s
#
# $server_puppetserver_jruby9k::            For Puppetserver 5, use JRuby 9k? Defaults to false
#
# $server_puppetserver_metrics::            Enable puppetserver http-client metrics
#                                           Defaults to false because that's the Puppet Inc. default behaviour.
#
# $server_puppetserver_profiler::           Enable JRuby profiling.
#                                           Defaults to false because that's the Puppet Inc. default behaviour.
#
# $server_metrics_jmx_enable::              Enable or disable JMX metrics reporter. Defaults to true
#
# $server_metrics_graphite_enable::         Enable or disable Graphite metrics reporter. Defaults to false
#
# $server_metrics_graphite_host::           Graphite server host. Defaults to "127.0.0.1"
#
# $server_metrics_graphite_port::           Graphite server port. Defaults to 2003
#
# $server_metrics_server_id::               A server id that will be used as part of the namespace for metrics produced
#                                           Defaults to $fqdn
#
# $server_metrics_graphite_interval::       How often to send metrics to graphite (in seconds)
#                                           Defaults to 5
#
# $server_metrics_allowed::                 Specify metrics to allow in addition to those in the default list
#                                           Defaults to undef
#
# $server_puppetserver_experimental::       For Puppetserver 5, enable the /puppet/experimental route? Defaults to true
#
# $server_puppetserver_auth_template::      Template for generating /etc/puppetlabs/puppetserver/conf.d/auth.conf 
#
# $server_puppetserver_trusted_agents::     Certificate names of puppet agents that are allowed to fetch *all* catalogs
#                                           Defaults to [] and all agents are only allowed to fetch their own catalogs.
#
# $server_puppetserver_trusted_certificate_extensions:: An array of hashes of certificate extensions and values to be used in auth.conf
#                                           A puppet client certificate containing valid extension(s) will be allowed to fetch
#                                           *any* catalog.
#                                           Defaults to [] and no certificate extensions are recognised as being allowed
#                                           to fetch *any* catalog.
#                                           Example: [{ 'pp_authorization' => 'catalog' }]
#                                           Any client certificate containing the `pp_authorization` extension with value `catalog`
#                                           will be permitted to fetch any catalog.
#                                           Complicated example: [
#                                             { '1.3.6.1.4.1.34380.1.3.1'  => 'catalog' },
#                                             { '1.3.6.1.4.1.34380.1.1.13' => 'jenkins_server', '1.3.6.1.4.1.34380.1.1.24' => 'prod' }
#                                           ]
#                                           Clients presenting a certificate with `pp_authorization = catalog` *or* with `pp_role`
#                                           *and* `pp_apptier` extensions set
#                                           correctly will be authorized to fetch any catalog.
#                                           NB. If server_ca == false, use oids instead of extension shortnames.
#                                           See https://tickets.puppetlabs.com/browse/SERVER-1689
#
# $server_compile_mode::                    Used to control JRuby's "CompileMode", which may improve performance.
#                                           Defaults to undef (off).
#
# $server_parser::                          Sets the parser to use. Valid options are 'current' or 'future'.
#                                           Defaults to 'current'.
#
# $server_acceptor_threads::                This sets the number of threads that the webserver will dedicate to accepting
#                                           socket connections for unencrypted HTTP traffic. If not provided, the webserver
#                                           defaults to the number of virtual cores on the host divided by 8, with a minimum
#                                           of 1 and maximum of 4.
#
# $server_selector_threads::                This sets the number of selectors that the webserver will dedicate to processing
#                                           events on connected sockets for unencrypted HTTPS traffic. If not provided,
#                                           the webserver defaults to the minimum of: virtual cores on the host divided by 2
#                                           or max-threads divided by 16, with a minimum of 1.
#
# $server_max_threads::                     This sets the maximum number of threads assigned to responding to HTTP and/or
#                                           HTTPS requests for a single webserver, effectively changing how many
#                                           concurrent requests can be made at one time. If not provided, the
#                                           webserver defaults to 200.
#
# $server_ssl_acceptor_threads::            This sets the number of threads that the webserver will dedicate to accepting
#                                           socket connections for encrypted HTTPS traffic. If not provided, defaults to
#                                           the number of virtual cores on the host divided by 8, with a minimum of 1 and maximum of 4.
#
# $server_ssl_selector_threads::            This sets the number of selectors that the webserver will dedicate to processing
#                                           events on connected sockets for encrypted HTTPS traffic. Defaults to the number of
#                                           virtual cores on the host divided by 2, with a minimum of 1 and maximum of 4.
#                                           The number of selector threads actually used by Jetty is twice the number of selectors
#                                           requested. For example, if a value of 3 is specified for the ssl-selector-threads setting,
#                                           Jetty will actually use 6 selector threads.
#
# $server_ca_allow_sans::                   Allow CA to sign certificate requests that have Subject Alternative Names
#                                           Defaults to false
#
# $server_ca_allow_auth_extensions::        Allow CA to sign certificate requests that have authorization extensions
#                                           Defaults to false
#
# $server_ca_enable_infra_crl::             Enable the separate CRL for Puppet infrastructure nodes
#                                           Defaults to false
#
# $server_max_open_files::                  Increase the max open files limit for Puppetserver.
#                                           Defaults to undef
#
# $server_versioned_code_id::               The path to an executable script that Puppet Server invokes to generate a code_id
#                                           Defaults to undef
#
# $server_versioned_code_content::          Contains the path to an executable script that Puppet Server
#                                           invokes when on static_file_content requests.
#                                           Defaults to undef
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
#     version    => '6.11.0-1',
#   }
#
class puppet (
  String $version = $puppet::params::version,
  String $user = $puppet::params::user,
  String $group = $puppet::params::group,
  Stdlib::Absolutepath $dir = $puppet::params::dir,
  Stdlib::Absolutepath $codedir = $puppet::params::codedir,
  Stdlib::Absolutepath $vardir = $puppet::params::vardir,
  Stdlib::Absolutepath $logdir = $puppet::params::logdir,
  Stdlib::Absolutepath $rundir = $puppet::params::rundir,
  Stdlib::Absolutepath $ssldir = $puppet::params::ssldir,
  Stdlib::Absolutepath $sharedir = $puppet::params::sharedir,
  Variant[Boolean, Enum['server', 'agent']] $manage_packages = $puppet::params::manage_packages,
  Optional[String] $dir_owner = $puppet::params::dir_owner,
  Optional[String] $dir_group = $puppet::params::dir_group,
  Optional[String] $package_provider = $puppet::params::package_provider,
  Optional[Variant[String,Hash]] $package_install_options = $puppet::params::package_install_options,
  Optional[Variant[Stdlib::Absolutepath, Stdlib::HTTPUrl]] $package_source = $puppet::params::package_source,
  Integer[0, 65535] $port = $puppet::params::port,
  Boolean $pluginsync = $puppet::params::pluginsync,
  Boolean $splay = $puppet::params::splay,
  Variant[Integer[0],Pattern[/^\d+[smhdy]?$/]] $splaylimit = $puppet::params::splaylimit,
  Variant[Boolean, Stdlib::Absolutepath] $autosign = $puppet::params::autosign,
  Array[String] $autosign_entries = $puppet::params::autosign_entries,
  Pattern[/^[0-9]{3,4}$/] $autosign_mode = $puppet::params::autosign_mode,
  Optional[String] $autosign_content = $puppet::params::autosign_content,
  Optional[String] $autosign_source = $puppet::params::autosign_source,
  Variant[Integer[0],Pattern[/^\d+[smhdy]?$/]] $runinterval = $puppet::params::runinterval,
  Boolean $usecacheonfailure = $puppet::params::usecacheonfailure,
  Enum['cron', 'service', 'systemd.timer', 'none', 'unmanaged'] $runmode = $puppet::params::runmode,
  Optional[Integer[0,23]] $run_hour = undef,
  Optional[Integer[0,59]] $run_minute = undef,
  Array[Enum['cron', 'service', 'systemd.timer', 'none']] $unavailable_runmodes = $puppet::params::unavailable_runmodes,
  Optional[String] $cron_cmd = $puppet::params::cron_cmd,
  Optional[String] $systemd_cmd = $puppet::params::systemd_cmd,
  Integer[0] $systemd_randomizeddelaysec = $puppet::params::systemd_randomizeddelaysec,
  Boolean $agent_noop = $puppet::params::agent_noop,
  Boolean $show_diff = $puppet::params::show_diff,
  Optional[Stdlib::HTTPUrl] $module_repository = $puppet::params::module_repository,
  Optional[Integer[0]] $http_connect_timeout = $puppet::params::http_connect_timeout,
  Optional[Integer[0]] $http_read_timeout = $puppet::params::http_read_timeout,
  Optional[Variant[String, Boolean]] $ca_server = $puppet::params::ca_server,
  Optional[Integer[0, 65535]] $ca_port = $puppet::params::ca_port,
  Optional[String] $ca_crl_filepath = $puppet::params::ca_crl_filepath,
  Optional[String] $prerun_command = $puppet::params::prerun_command,
  Optional[String] $postrun_command = $puppet::params::postrun_command,
  Array[String] $dns_alt_names = $puppet::params::dns_alt_names,
  Boolean $use_srv_records = $puppet::params::use_srv_records,
  Optional[String] $srv_domain = $puppet::params::srv_domain,
  String $pluginsource = $puppet::params::pluginsource,
  String $pluginfactsource = $puppet::params::pluginfactsource,
  Hash[String, Data] $additional_settings = $puppet::params::additional_settings,
  Hash[String, Data] $agent_additional_settings = $puppet::params::agent_additional_settings,
  Optional[String] $agent_restart_command = $puppet::params::agent_restart_command,
  String $classfile = $puppet::params::classfile,
  String $hiera_config = $puppet::params::hiera_config,
  String $auth_template = $puppet::params::auth_template,
  Boolean $allow_any_crl_auth = $puppet::params::allow_any_crl_auth,
  Array[String] $auth_allowed = $puppet::params::auth_allowed,
  Variant[String, Array[String]] $client_package = $puppet::params::client_package,
  Boolean $agent = $puppet::params::agent,
  Boolean $remove_lock = $puppet::params::remove_lock,
  Boolean $report = $puppet::params::report,
  Variant[String, Boolean] $client_certname = $puppet::params::client_certname,
  Optional[String] $puppetmaster = $puppet::params::puppetmaster,
  String $systemd_unit_name = $puppet::params::systemd_unit_name,
  String $service_name = $puppet::params::service_name,
  Optional[String] $syslogfacility = $puppet::params::syslogfacility,
  String $environment = $puppet::params::environment,
  Boolean $server = $puppet::params::server,
  Array[String] $server_admin_api_whitelist = $puppet::params::server_admin_api_whitelist,
  Boolean $server_manage_user = $puppet::params::manage_user,
  String $server_user = $puppet::params::user,
  String $server_group = $puppet::params::group,
  String $server_dir = $puppet::params::dir,
  String $server_ip = $puppet::params::ip,
  Integer $server_port = $puppet::params::port,
  Boolean $server_ca = $puppet::params::server_ca,
  Boolean $server_ca_crl_sync = $puppet::params::server_ca_crl_sync,
  Optional[Boolean] $server_crl_enable = $puppet::params::server_crl_enable,
  Boolean $server_ca_auth_required = $puppet::params::server_ca_auth_required,
  Boolean $server_ca_client_self_delete = $puppet::params::server_ca_client_self_delete,
  Array[String] $server_ca_client_whitelist = $puppet::params::server_ca_client_whitelist,
  Optional[Puppet::Custom_trusted_oid_mapping] $server_custom_trusted_oid_mapping = $puppet::params::server_custom_trusted_oid_mapping,
  Boolean $server_http = $puppet::params::server_http,
  Integer $server_http_port = $puppet::params::server_http_port,
  String $server_reports = $puppet::params::server_reports,
  Optional[Stdlib::Absolutepath] $server_puppetserver_dir = $puppet::params::server_puppetserver_dir,
  Optional[Stdlib::Absolutepath] $server_puppetserver_vardir = $puppet::params::server_puppetserver_vardir,
  Optional[Stdlib::Absolutepath] $server_puppetserver_rundir = $puppet::params::server_puppetserver_rundir,
  Optional[Stdlib::Absolutepath] $server_puppetserver_logdir = $puppet::params::server_puppetserver_logdir,
  Optional[Pattern[/^[\d]\.[\d]+\.[\d]+$/]] $server_puppetserver_version = $puppet::params::server_puppetserver_version,
  Variant[Undef, String[0], Stdlib::Absolutepath] $server_external_nodes = $puppet::params::server_external_nodes,
  Optional[Stdlib::Absolutepath] $server_trusted_external_command = $puppet::params::server_trusted_external_command,
  Array[String] $server_cipher_suites = $puppet::params::server_cipher_suites,
  Optional[String] $server_config_version = $puppet::params::server_config_version,
  Integer[0] $server_connect_timeout = $puppet::params::server_connect_timeout,
  Boolean $server_git_repo = $puppet::params::server_git_repo,
  Boolean $server_default_manifest = $puppet::params::server_default_manifest,
  Stdlib::Absolutepath $server_default_manifest_path = $puppet::params::server_default_manifest_path,
  String $server_default_manifest_content = $puppet::params::server_default_manifest_content,
  String $server_environments_owner = $puppet::params::server_environments_owner,
  Optional[String] $server_environments_group = $puppet::params::server_environments_group,
  Pattern[/^[0-9]{3,4}$/] $server_environments_mode = $puppet::params::server_environments_mode,
  Stdlib::Absolutepath $server_envs_dir = $puppet::params::server_envs_dir,
  Optional[Stdlib::Absolutepath] $server_envs_target = $puppet::params::server_envs_target,
  Variant[Undef, String[0], Array[Stdlib::Absolutepath]] $server_common_modules_path = $puppet::params::server_common_modules_path,
  Pattern[/^[0-9]{3,4}$/] $server_git_repo_mode = $puppet::params::server_git_repo_mode,
  Stdlib::Absolutepath $server_git_repo_path = $puppet::params::server_git_repo_path,
  String $server_git_repo_group = $puppet::params::server_git_repo_group,
  String $server_git_repo_user = $puppet::params::server_git_repo_user,
  Hash[String, String] $server_git_branch_map = $puppet::params::server_git_branch_map,
  Integer[0] $server_idle_timeout = $puppet::params::server_idle_timeout,
  String $server_post_hook_content = $puppet::params::server_post_hook_content,
  String $server_post_hook_name = $puppet::params::server_post_hook_name,
  Boolean $server_storeconfigs = $puppet::params::server_storeconfigs,
  Array[Stdlib::Absolutepath] $server_ruby_load_paths = $puppet::params::server_ruby_load_paths,
  Stdlib::Absolutepath $server_ssl_dir = $puppet::params::server_ssl_dir,
  Boolean $server_ssl_dir_manage = $puppet::params::server_ssl_dir_manage,
  Boolean $server_ssl_key_manage = $puppet::params::server_ssl_key_manage,
  Array[String] $server_ssl_protocols = $puppet::params::server_ssl_protocols,
  Optional[Stdlib::Absolutepath] $server_ssl_chain_filepath = $puppet::params::server_ssl_chain_filepath,
  Optional[Variant[String, Array[String]]] $server_package = $puppet::params::server_package,
  Optional[String] $server_version = $puppet::params::server_version,
  String $server_certname = $puppet::params::server_certname,
  Integer[0] $server_request_timeout = $puppet::params::server_request_timeout,
  Boolean $server_strict_variables = $puppet::params::server_strict_variables,
  Hash[String, Data] $server_additional_settings = $puppet::params::server_additional_settings,
  Boolean $server_foreman = $puppet::params::server_foreman,
  Stdlib::HTTPUrl $server_foreman_url = $puppet::params::server_foreman_url,
  Optional[Stdlib::Absolutepath] $server_foreman_ssl_ca = $puppet::params::server_foreman_ssl_ca,
  Optional[Stdlib::Absolutepath] $server_foreman_ssl_cert = $puppet::params::server_foreman_ssl_cert,
  Optional[Stdlib::Absolutepath] $server_foreman_ssl_key = $puppet::params::server_foreman_ssl_key,
  Boolean $server_foreman_facts = $puppet::params::server_foreman_facts,
  Optional[Stdlib::Absolutepath] $server_puppet_basedir = $puppet::params::server_puppet_basedir,
  Enum['current', 'future'] $server_parser = $puppet::params::server_parser,
  Variant[Undef, Enum['unlimited'], Pattern[/^\d+[smhdy]?$/]] $server_environment_timeout = $puppet::params::server_environment_timeout,
  String $server_jvm_java_bin = $puppet::params::server_jvm_java_bin,
  String $server_jvm_config = $puppet::params::server_jvm_config,
  Pattern[/^[0-9]+[kKmMgG]$/] $server_jvm_min_heap_size = $puppet::params::server_jvm_min_heap_size,
  Pattern[/^[0-9]+[kKmMgG]$/] $server_jvm_max_heap_size = $puppet::params::server_jvm_max_heap_size,
  Optional[Variant[String,Array[String]]] $server_jvm_extra_args = $puppet::params::server_jvm_extra_args,
  Optional[String] $server_jvm_cli_args = $puppet::params::server_jvm_cli_args,
  Optional[Stdlib::Absolutepath] $server_jruby_gem_home = $puppet::params::server_jruby_gem_home,
  Integer[1] $server_max_active_instances = $puppet::params::server_max_active_instances,
  Integer[0] $server_max_requests_per_instance = $puppet::params::server_max_requests_per_instance,
  Integer[0] $server_max_queued_requests = $puppet::params::server_max_queued_requests,
  Integer[0] $server_max_retry_delay = $puppet::params::server_max_retry_delay,
  Boolean $server_multithreaded = $puppet::params::server_multithreaded,
  Boolean $server_use_legacy_auth_conf = $puppet::params::server_use_legacy_auth_conf,
  Boolean $server_check_for_updates = $puppet::params::server_check_for_updates,
  Boolean $server_environment_class_cache_enabled = $puppet::params::server_environment_class_cache_enabled,
  Boolean $server_allow_header_cert_info = $puppet::params::server_allow_header_cert_info,
  Integer[0] $server_web_idle_timeout = $puppet::params::server_web_idle_timeout,
  Boolean $server_puppetserver_jruby9k = $puppet::params::server_puppetserver_jruby9k,
  Boolean $server_puppetserver_metrics = false,
  Boolean $server_puppetserver_profiler = false,
  Boolean $server_metrics_jmx_enable = $puppet::params::server_metrics_jmx_enable,
  Boolean $server_metrics_graphite_enable = $puppet::params::server_metrics_graphite_enable,
  String $server_metrics_graphite_host = $puppet::params::server_metrics_graphite_host,
  Integer $server_metrics_graphite_port = $puppet::params::server_metrics_graphite_port,
  String $server_metrics_server_id = $puppet::params::server_metrics_server_id,
  Integer $server_metrics_graphite_interval = $puppet::params::server_metrics_graphite_interval,
  Optional[Array] $server_metrics_allowed = $puppet::params::server_metrics_allowed,
  Boolean $server_puppetserver_experimental = $puppet::params::server_puppetserver_experimental,
  Optional[String[1]] $server_puppetserver_auth_template = $puppet::params::server_puppetserver_auth_template,
  Array[String] $server_puppetserver_trusted_agents = $puppet::params::server_puppetserver_trusted_agents,
  Array[Hash] $server_puppetserver_trusted_certificate_extensions = $puppet::params::server_puppetserver_trusted_certificate_extensions,
  Optional[Enum['off', 'jit', 'force']] $server_compile_mode = $puppet::params::server_compile_mode,
  Optional[Integer[1]] $server_acceptor_threads = undef,
  Optional[Integer[1]] $server_selector_threads = undef,
  Optional[Integer[1]] $server_ssl_acceptor_threads = undef,
  Optional[Integer[1]] $server_ssl_selector_threads = undef,
  Optional[Integer[1]] $server_max_threads = undef,
  Boolean $server_ca_allow_sans = $puppet::params::server_ca_allow_sans,
  Boolean $server_ca_allow_auth_extensions = $puppet::params::server_ca_allow_auth_extensions,
  Boolean $server_ca_enable_infra_crl = $puppet::params::server_ca_enable_infra_crl,
  Optional[Integer[1]] $server_max_open_files = $puppet::params::server_max_open_files,
  Optional[Stdlib::Absolutepath] $server_versioned_code_id = undef,
  Optional[Stdlib::Absolutepath] $server_versioned_code_content = undef,
  Boolean $generate_ca_cert = $puppet::params::generate_ca_cert,

) inherits puppet::params {
  contain puppet::config

  if $agent == true {
    contain puppet::agent
  }

  if $server == true {
    contain puppet::server
  }

  # Ensure the server is running before the agent needs it, and that
  # certificates are generated in the server config (if enabled)
  if $server == true and $agent == true {
    Class['puppet::server'] -> Class['puppet::agent::service']
  }
}
