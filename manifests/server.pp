# == Class: puppet::server
#
# Sets up a puppet server.
#
# == puppet::server parameters
#
# $autosign::                          If set to a boolean, autosign is enabled or disabled
#                                      for all incoming requests. Otherwise this has to be
#                                      set to the full file path of an autosign.conf file or
#                                      an autosign script. If this is set to a script, make
#                                      sure that script considers the content of autosign.conf
#                                      as otherwise Foreman functionality might be broken.
#
# $autosign_entries::                  A list of certnames or domain name globs
#                                      whose certificate requests will automatically be signed.
#                                      Defaults to an empty Array.
#
# $autosign_mode::                     mode of the autosign file/script
#
# $autosign_content::                  If set, write the autosign file content
#                                      using the value of this parameter.
#                                      Cannot be used at the same time as autosign_entries
#                                      For example, could be a string, or
#                                      file('another_module/autosign.sh') or
#                                      template('another_module/autosign.sh.erb')
#
# $autosign_source::                   If set, use this as the source for the autosign file,
#                                      instead of autosign_content.
#
# $hiera_config::                      The hiera configuration file.
#
# $manage_user::                       Whether to manage the puppet user resource
#
# $user::                              Name of the puppetserver user.
#
# $group::                             Name of the puppetserver group.
#
# $dir::                               Puppet configuration directory
#
# $ip::                                Bind ip address of the puppetserver
#
# $port::                              Puppet server port
#
# $ca::                                Provide puppet CA
#
# $ca_crl_filepath::                   Path to ca_crl file
#
# $ca_crl_sync::                       Sync the puppet ca crl to compilers. Requires compilers to
#                                      be agents of the CA server (primary server) defaults to false
#
# $crl_enable::                        Enable CRL processing, defaults to true when $ca is true else defaults
#                                      to false
#
# $http::                              Should the puppet server listen on HTTP as well as HTTPS.
#                                      Useful for load balancer or reverse proxy scenarios.
#
# $http_port::                         Puppet server HTTP port; defaults to 8139.
#
# $reports::                           List of report types to include on the puppetserver
#
# $external_nodes::                    External nodes classifier executable
#
# $trusted_external_command::          The external trusted facts script to use.
#
# $git_repo::                          Use git repository as a source of modules
#
# $environments_owner::                The owner of the environments directory
#
# $environments_group::                The group owning the environments directory
#
# $environments_mode::                 Environments directory mode.
#
# $environments_recurse::              Should the environments directory be managed recursively
#
# $envs_dir::                          List of directories that hold puppet environments
#                                      All listed directories will be created and attributes managed,
#                                      but only the first listed path will be used to populate
#                                      environments from git repo branches.
#
# $envs_target::                       Indicates that $envs_dir should be
#                                      a symbolic link to this target
#
# $common_modules_path::               Common modules paths
#
# $git_repo_path::                     Git repository path on disk
#
# $git_repo_umask::                    Umask used during git operations
#
# $git_repo_hook_mode::                Git repository hook mode
#
# $git_repo_group::                    Git repository group
#
# $git_repo_user::                     Git repository user
#
# $git_branch_map::                    Git branch to puppet env mapping for the
#                                      default post receive hook
#
# $post_hook_content::                 Which template to use for git post hook
#
# $post_hook_name::                    Name of a git hook
#
# $storeconfigs::                      Whether to enable storeconfigs
#
# $ssl_dir::                           SSL directory
#
# $package::                           Custom package name for puppet server
#
# $version::                           Custom package version for puppet server
#
# $certname::                          The name to use when handling certificates.
#
# $strict_variables::                  if set to true, it will throw parse errors
#                                      when accessing undeclared variables.
#
# $additional_settings::               A hash of additional settings.
#                                      Example: {trusted_node_data => true, ordering => 'manifest'}
#
# $parser::                            Sets the parser to use. Valid options are 'current' or 'future'.
#                                      Defaults to 'current'.
#
# $max_open_files::                    Increase the max open files limit for Puppetserver.
#
#
# === Advanced server parameters:
#
# $codedir::                           Override the puppet code directory.
#
# $server_foreman_facts::              Should foreman receive facts from puppet
#
# $foreman::                           Should foreman integration be installed
#
# $foreman_url::                       Foreman URL
#
# $foreman_ssl_ca::                    SSL CA of the Foreman server
#
# $foreman_ssl_cert::                  Client certificate for authenticating against Foreman server
#
# $foreman_ssl_key::                   Key for authenticating against Foreman server
#
# $puppet_basedir::                    Where is the puppet code base located
#
# $compile_mode::                      Used to control JRuby's "CompileMode", which may improve performance.
#
#
# $request_timeout::                   Timeout in node.rb script for fetching
#                                      catalog from Foreman (in seconds).
#
# $environment_timeout::               Timeout for cached compiled catalogs (10s, 5m, ...)
#
# $jvm_java_bin::                      Set the default java to use.
#
# $jvm_config::                        Specify the puppetserver jvm configuration file.
#
# $jvm_min_heap_size::                 Specify the minimum jvm heap space.
#
# $jvm_max_heap_size::                 Specify the maximum jvm heap space.
#
# $jvm_extra_args::                    Additional java options to pass through.
#                                      This can be used for Java versions prior to
#                                      Java 8 to specify the max perm space to use:
#                                      For example: '-XX:MaxPermSize=128m'.
#
# $jvm_cli_args::                      Java options to use when using puppetserver
#                                      subcommands (eg puppetserver gem).
#
# $jruby_gem_home::                    Where jruby gems are located for puppetserver
#
# $server_environment_vars::           A hash of environment variables and their values
#                                      which the puppetserver is allowed to see.
#                                      To pass an existing variable use {'MYVAR': '${MYVAR}'}.
#
# $default_manifest::                  Toggle if default_manifest setting should
#                                      be added to the [main] section
#
# $default_manifest_path::             A string setting the path to the default_manifest
#
# $default_manifest_content::          A string to set the content of the default_manifest
#                                      If set to '' it will not manage the file
#
# $ssl_dir_manage::                    Toggle if ssl_dir should be added to the [server]
#                                      configuration section. This is necessary to
#                                      disable in case CA is delegated to a separate instance
#
# $ssl_key_manage::                    Toggle if "private_keys/${::puppet::server::certname}.pem"
#                                      should be created with default user and group. This is used in
#                                      the default Forman setup to reuse the key for TLS communication.
#
# $puppetserver_vardir::               The path of the puppetserver var dir
#
# $puppetserver_rundir::               The path of the puppetserver run dir
#
# $puppetserver_logdir::               The path of the puppetserver log dir
#
# $puppetserver_dir::                  The path of the puppetserver config dir
#
# $puppetserver_version::              The version of puppetserver installed (or being installed)
#                                      Unfortunately, different versions of puppetserver need configuring differently.
#                                      By default we attempt to derive the version from the puppet version itself but
#                                      can be overriden if you're installing an older version.
#
# $max_active_instances::              Max number of active jruby instances. Defaults to
#                                      processor count
#
# $max_requests_per_instance::         Max number of requests per jruby instance. Defaults to 0 (disabled)
#
# $max_queued_requests::               The maximum number of requests that may be queued waiting to borrow a
#                                      JRuby from the pool.
#                                      Defaults to 0 (disabled).
#
# $max_retry_delay::                   Sets the upper limit for the random sleep set as a Retry-After header on
#                                      503 responses returned when max-queued-requests is enabled.
#                                      Defaults to 1800 for
#
# $multithreaded::                     Use multithreaded jruby. Defaults to false.
#
# $idle_timeout::                      How long the server will wait for a response on an existing connection
#
# $connect_timeout::                   How long the server will wait for a response to a connection attempt
#
# $web_idle_timeout::                  Time in ms that Jetty allows a socket to be idle, after processing has completed.
#                                      Defaults to the Jetty default of 30s
#
# $ssl_protocols::                     Array of SSL protocols to use.
#                                      Defaults to [ 'TLSv1.3', 'TLSv1.2' ]
#
# $ssl_chain_filepath::                Path to certificate chain for puppetserver
#                                      Defaults to "${ssl_dir}/ca/ca_crt.pem"
#
# $cipher_suites::                     List of SSL ciphers to use in negotiation
#                                      Defaults to [ 'TLS_RSA_WITH_AES_256_CBC_SHA256', 'TLS_RSA_WITH_AES_256_CBC_SHA',
#                                      'TLS_RSA_WITH_AES_128_CBC_SHA256', 'TLS_RSA_WITH_AES_128_CBC_SHA', ]
#
# $ruby_load_paths::                   List of ruby paths
#
# $ca_client_allowlist::               The allowlist of client certificates that
#                                      can query the certificate-status endpoint
#                                      Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#
# $custom_trusted_oid_mapping::        A hash of custom trusted oid mappings.
#                                      Example: { 1.3.6.1.4.1.34380.1.2.1.1 => { shortname => 'myshortname' } }
#
# $admin_api_allowlist::               The allowlist of clients that
#                                      can query the puppet-admin-api endpoint
#                                      Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#
# $ca_auth_required::                  Whether client certificates are needed to access the puppet-admin api
#                                      Defaults to true
#
# $ca_client_self_delete::             Adds a rule to auth.conf, that allows a client to self delete its own certificate
#                                      Defaults to false
#
# $check_for_updates::                 Should the puppetserver phone home to check for available updates?
#
# $environment_class_cache_enabled::   Enable environment class cache in conjunction with the use of the
#                                      environment_classes API.
#
#
# $allow_header_cert_info::            Allow client authentication over HTTP Headers
#                                      Defaults to false, is also activated by the $http setting
#
# $puppetserver_metrics::              Enable puppetserver http-client metrics
#                                      Defaults to false because that's the Puppet Inc. default behaviour.
#
# $puppetserver_profiler::             Enable JRuby profiling.
#                                      Defaults to false because that's the Puppet Inc. default behaviour.
#
# $puppetserver_telemetry::            Enable Dropsonde telemetry.
#                                      Undef means disabled while booleans are explicit opt-in or opt-out.
#                                      This is different from Puppetserver's default values.
#
# $metrics_jmx_enable::                Enable or disable JMX metrics reporter. Defaults to true
#
# $metrics_graphite_enable::           Enable or disable Graphite metrics reporter. Defaults to false
#
# $metrics_graphite_host::             Graphite server host. Defaults to "127.0.0.1"
#
# $metrics_graphite_port::             Graphite server port. Defaults to 2003
#
# $metrics_server_id::                 A server id that will be used as part of the namespace for metrics produced
#                                      Defaults to $fqdn
#
# $metrics_graphite_interval::         How often to send metrics to graphite (in seconds)
#                                      Defaults to 5
#
# $metrics_allowed::                   Specify metrics to allow in addition to those in the default list
#                                      Defaults to undef
#
# $puppetserver_experimental::         Enable the /puppet/experimental route? Defaults to true
#
# $puppetserver_auth_template::        Template for generating /etc/puppetlabs/puppetserver/conf.d/auth.conf
#
# $puppetserver_trusted_agents::       Certificate names of agents that are allowed to fetch *all* catalogs. Defaults to empty array
#
# $puppetserver_trusted_certificate_extensions:: An array of hashes of certificate extensions and values.
#                                      Example: [{ 'pp_authorization' => 'catalog' }]
#
# $ca_allow_sans::                     Allow CA to sign certificate requests that have Subject Alternative Names
#                                      Defaults to false
#
# $ca_allow_auth_extensions::          Allow CA to sign certificate requests that have authorization extensions
#                                      Defaults to false
#
# $ca_enable_infra_crl::               Enable the separate CRL for Puppet infrastructure nodes
#                                      Defaults to false
# $server_ca_allow_auto_renewal::           Enable the auto renewal for client certificates
#                                           Defaults to false
#
# $server_ca_allow_auto_renewal_cert_ttl::  Set the auto renewal interval for client certificates
#                                           Defaults to 60d
#
# $acceptor_threads::                  This sets the number of threads that the webserver will dedicate to accepting
#                                      socket connections for unencrypted HTTP traffic. If not provided, the webserver
#                                      defaults to the number of virtual cores on the host divided by 8, with a minimum
#                                      of 1 and maximum of 4.
#
# $selector_threads::                  This sets the number of selectors that the webserver will dedicate to processing
#                                      events on connected sockets for unencrypted HTTPS traffic. If not provided,
#                                      the webserver defaults to the minimum of: virtual cores on the host divided by 2
#                                      or max-threads divided by 16, with a minimum of 1.
#
# $max_threads::                       This sets the maximum number of threads assigned to responding to HTTP and/or
#                                      HTTPS requests for a single webserver, effectively changing how many
#                                      concurrent requests can be made at one time. If not provided, the
#                                      webserver defaults to 200.
#
# $ssl_acceptor_threads::              This sets the number of threads that the webserver will dedicate to accepting
#                                      socket connections for encrypted HTTPS traffic. If not provided, defaults to
#                                      the number of virtual cores on the host divided by 8, with a minimum of 1 and maximum of 4.
#
# $ssl_selector_threads::              This sets the number of selectors that the webserver will dedicate to processing
#                                      events on connected sockets for encrypted HTTPS traffic. Defaults to the number of
#                                      virtual cores on the host divided by 2, with a minimum of 1 and maximum of 4.
#                                      The number of selector threads actually used by Jetty is twice the number of selectors
#                                      requested. For example, if a value of 3 is specified for the ssl-selector-threads setting,
#                                      Jetty will actually use 6 selector threads.
#
# $versioned_code_id::                 The path to an executable script that Puppet Server invokes to generate a code_id
#
# $versioned_code_content::            Contains the path to an executable script that Puppet Server invokes when an agent makes
#                                      a static_file_content API request for the contents of a file resource that
#                                      has a source attribute with a puppet:/// URI value.
#
# $jolokia_metrics_allowlist::         The allowlist of clients that
#                                      can query the jolokia /metrics/v2 endpoint
class puppet::server (
  Variant[Boolean, Stdlib::Absolutepath] $autosign = $puppet::autosign,
  Array[String] $autosign_entries = $puppet::autosign_entries,
  Pattern[/^[0-9]{3,4}$/] $autosign_mode = $puppet::autosign_mode,
  Optional[String] $autosign_content = $puppet::autosign_content,
  Optional[String] $autosign_source = $puppet::autosign_source,
  String $hiera_config = $puppet::hiera_config,
  Array[String] $admin_api_allowlist = $puppet::server_admin_api_allowlist,
  Boolean $manage_user = $puppet::server_manage_user,
  String $user = $puppet::server_user,
  String $group = $puppet::server_group,
  String $dir = $puppet::server_dir,
  Stdlib::Absolutepath $codedir = $puppet::codedir,
  Stdlib::Port $port = $puppet::server_port,
  String $ip = $puppet::server_ip,
  Boolean $ca = $puppet::server_ca,
  Optional[String] $ca_crl_filepath = $puppet::ca_crl_filepath,
  Boolean $ca_crl_sync = $puppet::server_ca_crl_sync,
  Optional[Boolean] $crl_enable = $puppet::server_crl_enable,
  Boolean $ca_auth_required = $puppet::server_ca_auth_required,
  Boolean $ca_client_self_delete = $puppet::server_ca_client_self_delete,
  Array[String] $ca_client_allowlist = $puppet::server_ca_client_allowlist,
  Optional[Puppet::Custom_trusted_oid_mapping] $custom_trusted_oid_mapping = $puppet::server_custom_trusted_oid_mapping,
  Boolean $http = $puppet::server_http,
  Stdlib::Port $http_port = $puppet::server_http_port,
  String $reports = $puppet::server_reports,
  Stdlib::Absolutepath $puppetserver_vardir = $puppet::server_puppetserver_vardir,
  Optional[Stdlib::Absolutepath] $puppetserver_rundir = $puppet::server_puppetserver_rundir,
  Optional[Stdlib::Absolutepath] $puppetserver_logdir = $puppet::server_puppetserver_logdir,
  Stdlib::Absolutepath $puppetserver_dir = $puppet::server_puppetserver_dir,
  Optional[Pattern[/^[\d]\.[\d]+\.[\d]+$/]] $puppetserver_version = $puppet::server_puppetserver_version,
  Variant[Undef, String[0], Stdlib::Absolutepath] $external_nodes = $puppet::server_external_nodes,
  Optional[Stdlib::Absolutepath] $trusted_external_command = $puppet::server_trusted_external_command,
  Array[String] $cipher_suites = $puppet::server_cipher_suites,
  Integer[0] $connect_timeout = $puppet::server_connect_timeout,
  Integer[0] $web_idle_timeout = $puppet::server_web_idle_timeout,
  Boolean $git_repo = $puppet::server_git_repo,
  Boolean $default_manifest = $puppet::server_default_manifest,
  Stdlib::Absolutepath $default_manifest_path = $puppet::server_default_manifest_path,
  String $default_manifest_content = $puppet::server_default_manifest_content,
  String $environments_owner = $puppet::server_environments_owner,
  Optional[String] $environments_group = $puppet::server_environments_group,
  Pattern[/^[0-9]{3,4}$/] $environments_mode = $puppet::server_environments_mode,
  Boolean $environments_recurse = $puppet::server_environments_recurse,
  Array[Stdlib::Absolutepath, 1] $envs_dir = $puppet::server_envs_dir,
  Optional[Stdlib::Absolutepath] $envs_target = $puppet::server_envs_target,
  Variant[Undef, String[0], Array[Stdlib::Absolutepath]] $common_modules_path = $puppet::server_common_modules_path,
  Pattern[/^[0-9]{3,4}$/] $git_repo_hook_mode = $puppet::server_git_repo_hook_mode,
  Stdlib::Absolutepath $git_repo_path = $puppet::server_git_repo_path,
  Pattern[/^[0-9]{3,4}$/] $git_repo_umask = $puppet::server_git_repo_umask,
  String $git_repo_group = $puppet::server_git_repo_group,
  String $git_repo_user = $puppet::server_git_repo_user,
  Hash[String, String] $git_branch_map = $puppet::server_git_branch_map,
  Integer[0] $idle_timeout = $puppet::server_idle_timeout,
  String $post_hook_content = $puppet::server_post_hook_content,
  String $post_hook_name = $puppet::server_post_hook_name,
  Boolean $storeconfigs = $puppet::server_storeconfigs,
  Array[Stdlib::Absolutepath] $ruby_load_paths = $puppet::server_ruby_load_paths,
  Stdlib::Absolutepath $ssl_dir = $puppet::server_ssl_dir,
  Boolean $ssl_dir_manage = $puppet::server_ssl_dir_manage,
  Boolean $ssl_key_manage = $puppet::server_ssl_key_manage,
  Array[String] $ssl_protocols = $puppet::server_ssl_protocols,
  Optional[Stdlib::Absolutepath] $ssl_chain_filepath = $puppet::server_ssl_chain_filepath,
  Optional[Variant[String, Array[String]]] $package = $puppet::server_package,
  Optional[String] $version = $puppet::server_version,
  String $certname = $puppet::server_certname,
  Integer[0] $request_timeout = $puppet::server_request_timeout,
  Boolean $strict_variables = $puppet::server_strict_variables,
  Hash[String, Data] $additional_settings = $puppet::server_additional_settings,
  Boolean $foreman = $puppet::server_foreman,
  Optional[Stdlib::HTTPUrl] $foreman_url = $puppet::server_foreman_url,
  Optional[Stdlib::Absolutepath] $foreman_ssl_ca = $puppet::server_foreman_ssl_ca,
  Optional[Stdlib::Absolutepath] $foreman_ssl_cert = $puppet::server_foreman_ssl_cert,
  Optional[Stdlib::Absolutepath] $foreman_ssl_key = $puppet::server_foreman_ssl_key,
  Boolean $server_foreman_facts = $puppet::server_foreman_facts,
  Optional[Stdlib::Absolutepath] $puppet_basedir = $puppet::server_puppet_basedir,
  Enum['current', 'future'] $parser = $puppet::server_parser,
  Variant[Undef, Enum['unlimited'], Pattern[/^\d+[smhdy]?$/]] $environment_timeout = $puppet::server_environment_timeout,
  Optional[Stdlib::Absolutepath] $jvm_java_bin = $puppet::server_jvm_java_bin,
  String $jvm_config = $puppet::server_jvm_config,
  Pattern[/^[0-9]+[kKmMgG]$/] $jvm_min_heap_size = $puppet::server_jvm_min_heap_size,
  Pattern[/^[0-9]+[kKmMgG]$/] $jvm_max_heap_size = $puppet::server_jvm_max_heap_size,
  Optional[Variant[String,Array[String]]] $jvm_extra_args = $puppet::server_jvm_extra_args,
  Optional[String] $jvm_cli_args = $puppet::server_jvm_cli_args,
  Optional[Stdlib::Absolutepath] $jruby_gem_home = $puppet::server_jruby_gem_home,
  Hash[String, String] $server_environment_vars = $puppet::server_environment_vars,
  Integer[1] $max_active_instances = $puppet::server_max_active_instances,
  Integer[0] $max_requests_per_instance = $puppet::server_max_requests_per_instance,
  Integer[0] $max_queued_requests = $puppet::server_max_queued_requests,
  Integer[0] $max_retry_delay = $puppet::server_max_retry_delay,
  Boolean $multithreaded = $puppet::server_multithreaded,
  Boolean $check_for_updates = $puppet::server_check_for_updates,
  Boolean $environment_class_cache_enabled = $puppet::server_environment_class_cache_enabled,
  Boolean $allow_header_cert_info = $puppet::server_allow_header_cert_info,
  Optional[Boolean] $puppetserver_metrics = $puppet::server_puppetserver_metrics,
  Boolean $puppetserver_profiler = $puppet::server_puppetserver_profiler,
  Optional[Boolean] $puppetserver_telemetry = $puppet::server_puppetserver_telemetry,
  Boolean $metrics_jmx_enable = $puppet::server_metrics_jmx_enable,
  Boolean $metrics_graphite_enable = $puppet::server_metrics_graphite_enable,
  String $metrics_graphite_host = $puppet::server_metrics_graphite_host,
  Stdlib::Port $metrics_graphite_port = $puppet::server_metrics_graphite_port,
  String $metrics_server_id = $puppet::server_metrics_server_id,
  Integer $metrics_graphite_interval = $puppet::server_metrics_graphite_interval,
  Variant[Undef, Array] $metrics_allowed = $puppet::server_metrics_allowed,
  Boolean $puppetserver_experimental = $puppet::server_puppetserver_experimental,
  Optional[String[1]] $puppetserver_auth_template = $puppet::server_puppetserver_auth_template,
  Array[String] $puppetserver_trusted_agents = $puppet::server_puppetserver_trusted_agents,
  Array[Hash] $puppetserver_trusted_certificate_extensions = $puppet::server_puppetserver_trusted_certificate_extensions,
  Optional[Enum['off', 'jit', 'force']] $compile_mode = $puppet::server_compile_mode,
  Optional[Integer[1]] $selector_threads = $puppet::server_selector_threads,
  Optional[Integer[1]] $acceptor_threads = $puppet::server_acceptor_threads,
  Optional[Integer[1]] $ssl_selector_threads = $puppet::server_ssl_selector_threads,
  Optional[Integer[1]] $ssl_acceptor_threads = $puppet::server_ssl_acceptor_threads,
  Optional[Integer[1]] $max_threads = $puppet::server_max_threads,
  Boolean $ca_allow_sans = $puppet::server_ca_allow_sans,
  Boolean $ca_allow_auth_extensions = $puppet::server_ca_allow_auth_extensions,
  Boolean $ca_enable_infra_crl = $puppet::server_ca_enable_infra_crl,
  Boolean $server_ca_allow_auto_renewal = $puppet::server_ca_allow_auto_renewal,
  String $server_ca_allow_auto_renewal_cert_ttl = $puppet::server_ca_allow_auto_renewal_cert_ttl,
  Optional[Integer[1]] $max_open_files = $puppet::server_max_open_files,
  Optional[Stdlib::Absolutepath] $versioned_code_id = $puppet::server_versioned_code_id,
  Optional[Stdlib::Absolutepath] $versioned_code_content = $puppet::server_versioned_code_content,
  Array[String[1]] $jolokia_metrics_allowlist = $puppet::server_jolokia_metrics_allowlist,
) {
  $cadir = "${puppetserver_dir}/ca"

  if $ca {
    $ssl_ca_cert     = "${cadir}/ca_crt.pem"
    $ssl_ca_crl      = "${cadir}/ca_crl.pem"
    $ssl_chain       = pick($ssl_chain_filepath, "${cadir}/ca_crt.pem")
    $crl_enable_real = pick($crl_enable, true)
  } else {
    $ssl_ca_cert     = "${ssl_dir}/certs/ca.pem"
    $ssl_ca_crl      = pick($ca_crl_filepath, "${ssl_dir}/crl.pem")
    $ssl_chain       = false
    $crl_enable_real = pick($crl_enable, false)
  }

  $ssl_cert      = "${ssl_dir}/certs/${certname}.pem"
  $ssl_cert_key  = "${ssl_dir}/private_keys/${certname}.pem"

  if $jvm_extra_args {
    $real_jvm_extra_args = $jvm_extra_args
  } else {
    $real_jvm_extra_args = '-Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger'
  }

  contain puppet::server::install
  contain puppet::server::config
  contain puppet::server::service

  Class['puppet::server::install'] ~> Class['puppet::server::config']
  Class['puppet::config', 'puppet::server::config'] ~> Class['puppet::server::service']
}
