# == Class: puppet::server
#
# Sets up a puppet master.
#
# == puppet::server parameters
#
# $autosign::                  If set to a boolean, autosign is enabled or disabled
#                              for all incoming requests. Otherwise this has to be
#                              set to the full file path of an autosign.conf file or
#                              an autosign script. If this is set to a script, make
#                              sure that script considers the content of autosign.conf
#                              as otherwise Foreman functionality might be broken.
#
# $autosign_entries::          A list of certnames or domain name globs
#                              whose certificate requests will automatically be signed.
#                              Defaults to an empty Array.
#                              type: array
#
# $autosign_mode::             mode of the autosign file/script
#
# $hiera_config::              The hiera configuration file.
#                              type:string
#
# $user::                      Name of the puppetmaster user.
#                              type:string
#
# $group::                     Name of the puppetmaster group.
#                              type:string
#
# $dir::                       Puppet configuration directory
#                              type:string
#
# $ip::                        Bind ip address of the puppetmaster
#                              type:string
#
# $port::                      Puppet master port
#                              type:integer
#
# $ca::                        Provide puppet CA
#                              type:boolean
#
# $http::                      Should the puppet master listen on HTTP as well as HTTPS.
#                              Useful for load balancer or reverse proxy scenarios. Note that
#                              the HTTP puppet master denies access from all clients by default,
#                              allowed clients must be specified with $http_allow.
#                              type:boolean
#
# $http_port::                 Puppet master HTTP port; defaults to 8139.
#                              type:integer
#
# $http_allow::                Array of allowed clients for the HTTP puppet master. Passed
#                              to Apache's 'Allow' directive.
#                              type:array
#
# $reports::                   List of report types to include on the puppetmaster
#                              type:string
#
# $implementation::            Puppet master implementation, either "master" (traditional
#                              Ruby) or "puppetserver" (JVM-based)
#                              type:string
#
# $passenger::                 If set to true, we will configure apache with
#                              passenger. If set to false, we will enable the
#                              default puppetmaster service unless
#                              service_fallback is set to false. See 'Advanced
#                              server parameters' for more information.
#                              Only applicable when server_implementation is "master".
#                              type:boolean
#
# $external_nodes::            External nodes classifier executable
#                              type:string
#
# $git_repo::                  Use git repository as a source of modules
#                              type:boolean
#
# $dynamic_environments::      Use $environment in the modulepath
#                              Deprecated when $directory_environments is true,
#                              set $environments to [] instead.
#                              type:boolean
#
# $directory_environments::    Enable directory environments, defaulting to true
#                              with Puppet 3.6.0 or higher
#                              type:boolean
#
# $environments::              Environments to setup (creates directories).
#                              Applies only when $dynamic_environments
#                              is false
#                              type:array
#
# $environments_owner::        The owner of the environments directory
#                              type:string
#
# $environments_group::        The group owning the environments directory
#                              type:string
#
# $environments_mode::         Environments directory mode.
#                              type:string
#
# $envs_dir::                  Directory that holds puppet environments
#                              type:string
#
# $envs_target::               Indicates that $envs_dir should be
#                              a symbolic link to this target
#                              type:string
#
# $common_modules_path::       Common modules paths (only when
#                              $git_repo_path and $dynamic_environments
#                              are false)
#                              type:array
#
# $git_repo_path::             Git repository path
#                              type:string
#
# $git_repo_mode::             Git repository mode
#                              type:string
#
# $git_repo_group::            Git repository group
#                              type:string
#
# $git_repo_user::             Git repository user
#                              type:string
#
# $git_branch_map::            Git branch to puppet env mapping for the
#                              default post receive hook
#                              type:hash
#
# $post_hook_content::         Which template to use for git post hook
#                              type:string
#
# $post_hook_name::            Name of a git hook
#                              type:string
#
# $storeconfigs_backend::      Do you use storeconfigs? (note: not required)
#                              false if you don't, "active_record" for 2.X
#                              style db, "puppetdb" for puppetdb
#                              type:string
#
# $app_root::                  Directory where the application lives
#                              type:string
#
# $ssl_dir::                   SSL directory
#                              type:string
#
# $package::                   Custom package name for puppet master
#                              type:string
#
# $version::                   Custom package version for puppet master
#                              type:string
#
# $certname::                  The name to use when handling certificates.
#                              type:string
#
# $strict_variables::          if set to true, it will throw parse errors
#                              when accessing undeclared variables.
#                              type:boolean
#
# $additional_settings::       A hash of additional settings.
#                              Example: {trusted_node_data => true, ordering => 'manifest'}
#                              type:hash
#
# $rack_arguments::            Arguments passed to rack app ARGV in addition to --confdir and
#                              --vardir.  The default is an empty array.
#                              type:array
#
# $puppetdb_host::             PuppetDB host
#                              type:string
#
# $puppetdb_port::             PuppetDB port
#                              type:integer
#
# $puppetdb_swf::              PuppetDB soft_write_failure
#                              type:boolean
#
# $parser::                    Sets the parser to use. Valid options are 'current' or 'future'.
#                              Defaults to 'current'.
#                              type:string
#
# === Advanced server parameters:
#
# $httpd_service::             Apache/httpd service name to notify
#                              on configuration changes. Defaults
#                              to 'httpd' based on the default
#                              apache module included with foreman-installer.
#                              type:string
#
# $service_fallback::          If passenger is not used, do we want to fallback
#                              to using the puppetmaster service? Set to false
#                              if you disabled passenger and you do NOT want to
#                              use the puppetmaster service. Defaults to true.
#                              type:boolean
#
# $passenger_min_instances::   The PassengerMinInstances parameter. Sets the
#                              minimum number of application processes to run.
#                              Defaults to the number of processors on your
#                              system.
#                              type:integer
#
# $passenger_pre_start::       Pre-start the first passenger worker instance
#                              process during httpd start.
#                              type:boolean
#
# $passenger_ruby::            The PassengerRuby parameter. Sets the Ruby
#                              interpreter for serving the puppetmaster rack
#                              application.
#                              type:string
#
# $config_version::            How to determine the configuration version. When
#                              using git_repo, by default a git describe
#                              approach will be installed.
#                              type:string
#
# $server_facts::              Should foreman receive facts from puppet
#                              type:boolean
#
# $foreman::                   Should foreman integration be installed
#                              type:boolean
#
# $foreman_url::               Foreman URL
#                              type:string
#
# $foreman_ssl_ca::            SSL CA of the Foreman server
#                              type:string
#
# $foreman_ssl_cert::          Client certificate for authenticating against Foreman server
#                              type:string
#
# $foreman_ssl_key::           Key for authenticating against Foreman server
#                              type:string
#
# $puppet_basedir::            Where is the puppet code base located
#                              type:string
#
# $enc_api::                   What version of enc script to deploy. Valid
#                              values are 'v2' for latest, and 'v1'
#                              for Foreman =< 1.2
#                              type:string
#
# $report_api::                What version of report processor to deploy.
#                              Valid values are 'v2' for latest, and 'v1'
#                              for Foreman =< 1.2
#                              type:string
#
# $request_timeout::           Timeout in node.rb script for fetching
#                              catalog from Foreman (in seconds).
#                              type:integer
#
# $environment_timeout::       Timeout for cached compiled catalogs (10s, 5m, ...)
#                              type:string
#
# $ca_proxy::                  The actual server that handles puppet CA.
#                              Setting this to anything non-empty causes
#                              the apache vhost to set up a proxy for all
#                              certificates pointing to the value.
#                              type:string
#
# $jvm_java_bin::              Set the default java to use.
#                              type:string
#
# $jvm_config::                Specify the puppetserver jvm configuration file.
#                              type:string
#
# $jvm_min_heap_size::         Specify the minimum jvm heap space.
#                              type:string
#
# $jvm_max_heap_size::         Specify the maximum jvm heap space.
#                              type:string
#
# $jvm_extra_args::            Additional java options to pass through.
#                              This can be used for Java versions prior to
#                              Java 8 to specify the max perm space to use:
#                              For example: '-XX:MaxPermSpace=128m'.
#                              type:string
#
# $jruby_gem_home::            Where jruby gems are located for puppetserver
#                              type:string
#
# $allow_any_crl_auth::        Allow any authentication for the CRL. This
#                              is needed on the puppet CA to accept clients
#                              from a the puppet CA proxy.
#                              type:boolean
#
# $auth_allowed::              An array of authenticated nodes allowed to
#                              access all catalog and node endpoints.
#                              default to ['$1']
#                              type:array
#
# $default_manifest::          Toggle if default_manifest setting should
#                              be added to the [main] section
#                              type:boolean
#
# $default_manifest_path::     A string setting the path to the default_manifest
#                              type:string
#
# $default_manifest_content::  A string to set the content of the default_manifest
#                              If set to '' it will not manage the file
#                              type:string
#
# $ssl_dir_manage::            Toggle if ssl_dir should be added to the [master]
#                              configuration section. This is necessary to
#                              disable in case CA is delegated to a separate instance
#                              type:boolean
#
# $puppetserver_vardir::       The path of the puppetserver var dir
#                              type:string
#
# $puppetserver_dir::          The path of the puppetserver config dir
#                              type:string
#
# $puppetserver_version::      The version of puppetserver 2 installed (or being installed)
#                              Unfortunately, different versions of puppetserver need configuring differently,
#                              and there's no easy way of determining which version is being installed.
#                              Defaults to '2.3.1' but can be overriden if you're installing an older version.
#                              type:string
#
# $max_active_instances::      Max number of active jruby instances. Defaults to
#                              processor count
#                              type:integer
#
# $max_requests_per_instance:: Max number of requests per jruby instance. Defaults to 0 (disabled)
#                              type:integer
#
# $idle_timeout::              How long the server will wait for a response on an existing connection
#                              type:integer
#
# $connect_timeout::           How long the server will wait for a response to a connection attempt
#                              type:integer
#
# $ssl_protocols::             Array of SSL protocols to use.
#                              Defaults to [ 'TLSv1.2' ]
#                              type:array
#
# $cipher_suites::             List of SSL ciphers to use in negotiation
#                              Defaults to [ 'TLS_RSA_WITH_AES_256_CBC_SHA256', 'TLS_RSA_WITH_AES_256_CBC_SHA',
#                              'TLS_RSA_WITH_AES_128_CBC_SHA256', 'TLS_RSA_WITH_AES_128_CBC_SHA', ]
#                              type:array
#
# $ruby_load_paths::           List of ruby paths
#                              Defaults based on $::puppetversion
#                              type:array
#
# $ca_client_whitelist::       The whitelist of client certificates that
#                              can query the certificate-status endpoint
#                              Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#                              type:array
#
# $admin_api_whitelist::       The whitelist of clients that
#                              can query the puppet-admin-api endpoint
#                              Defaults to [ '127.0.0.1', '::1', $::ipaddress ]
#                              type:array
#
# $enable_ruby_profiler::      Should the puppetserver ruby profiler be enabled?
#                              Defaults to false
#                              type:boolean
#
# $ca_auth_required::          Whether client certificates are needed to access the puppet-admin api
#                              Defaults to true
#                              type:boolean
#
# $use_legacy_auth_conf::      Should the puppetserver use the legacy puppet auth.conf?
#                              Defaults to false (the puppetserver will use its own conf.d/auth.conf)
#                              type:boolean
#


class puppet::server(
  $autosign                  = $::puppet::autosign,
  $autosign_entries          = $::puppet::autosign_entries,
  $autosign_mode             = $::puppet::autosign_mode,
  $hiera_config              = $::puppet::hiera_config,
  $admin_api_whitelist       = $::puppet::server_admin_api_whitelist,
  $user                      = $::puppet::server_user,
  $group                     = $::puppet::server_group,
  $dir                       = $::puppet::server_dir,
  $codedir                   = $::puppet::codedir,
  $port                      = $::puppet::server_port,
  $ip                        = $::puppet::server_ip,
  $ca                        = $::puppet::server_ca,
  $ca_auth_required          = $::puppet::server_ca_auth_required,
  $ca_client_whitelist       = $::puppet::server_ca_client_whitelist,
  $http                      = $::puppet::server_http,
  $http_port                 = $::puppet::server_http_port,
  $http_allow                = $::puppet::server_http_allow,
  $reports                   = $::puppet::server_reports,
  $implementation            = $::puppet::server_implementation,
  $passenger                 = $::puppet::server_passenger,
  $puppetserver_vardir       = $::puppet::server_puppetserver_vardir,
  $puppetserver_rundir       = $::puppet::server_puppetserver_rundir,
  $puppetserver_logdir       = $::puppet::server_puppetserver_logdir,
  $puppetserver_dir          = $::puppet::server_puppetserver_dir,
  $puppetserver_version      = $::puppet::server_puppetserver_version,
  $service_fallback          = $::puppet::server_service_fallback,
  $passenger_min_instances   = $::puppet::server_passenger_min_instances,
  $passenger_pre_start       = $::puppet::server_passenger_pre_start,
  $passenger_ruby            = $::puppet::server_passenger_ruby,
  $httpd_service             = $::puppet::server_httpd_service,
  $external_nodes            = $::puppet::server_external_nodes,
  $cipher_suites             = $::puppet::server_cipher_suites,
  $config_version            = $::puppet::server_config_version,
  $connect_timeout           = $::puppet::server_connect_timeout,
  $git_repo                  = $::puppet::server_git_repo,
  $dynamic_environments      = $::puppet::server_dynamic_environments,
  $directory_environments    = $::puppet::server_directory_environments,
  $default_manifest          = $::puppet::server_default_manifest,
  $default_manifest_path     = $::puppet::server_default_manifest_path,
  $default_manifest_content  = $::puppet::server_default_manifest_content,
  $enable_ruby_profiler      = $::puppet::server_enable_ruby_profiler,
  $environments              = $::puppet::server_environments,
  $environments_owner        = $::puppet::server_environments_owner,
  $environments_group        = $::puppet::server_environments_group,
  $environments_mode         = $::puppet::server_environments_mode,
  $envs_dir                  = $::puppet::server_envs_dir,
  $envs_target               = $::puppet::server_envs_target,
  $common_modules_path       = $::puppet::server_common_modules_path,
  $git_repo_mode             = $::puppet::server_git_repo_mode,
  $git_repo_path             = $::puppet::server_git_repo_path,
  $git_repo_group            = $::puppet::server_git_repo_group,
  $git_repo_user             = $::puppet::server_git_repo_user,
  $git_branch_map            = $::puppet::server_git_branch_map,
  $idle_timeout              = $::puppet::server_idle_timeout,
  $post_hook_content         = $::puppet::server_post_hook_content,
  $post_hook_name            = $::puppet::server_post_hook_name,
  $storeconfigs_backend      = $::puppet::server_storeconfigs_backend,
  $app_root                  = $::puppet::server_app_root,
  $ruby_load_paths           = $::puppet::server_ruby_load_paths,
  $ssl_dir                   = $::puppet::server_ssl_dir,
  $ssl_dir_manage            = $::puppet::server_ssl_dir_manage,
  $ssl_protocols             = $::puppet::server_ssl_protocols,
  $package                   = $::puppet::server_package,
  $version                   = $::puppet::server_version,
  $certname                  = $::puppet::server_certname,
  $enc_api                   = $::puppet::server_enc_api,
  $report_api                = $::puppet::server_report_api,
  $request_timeout           = $::puppet::server_request_timeout,
  $ca_proxy                  = $::puppet::server_ca_proxy,
  $strict_variables          = $::puppet::server_strict_variables,
  $additional_settings       = $::puppet::server_additional_settings,
  $rack_arguments            = $::puppet::server_rack_arguments,
  $foreman                   = $::puppet::server_foreman,
  $foreman_url               = $::puppet::server_foreman_url,
  $foreman_ssl_ca            = $::puppet::server_foreman_ssl_ca,
  $foreman_ssl_cert          = $::puppet::server_foreman_ssl_cert,
  $foreman_ssl_key           = $::puppet::server_foreman_ssl_key,
  $server_facts              = $::puppet::server_facts,
  $puppet_basedir            = $::puppet::server_puppet_basedir,
  $puppetdb_host             = $::puppet::server_puppetdb_host,
  $puppetdb_port             = $::puppet::server_puppetdb_port,
  $puppetdb_swf              = $::puppet::server_puppetdb_swf,
  $parser                    = $::puppet::server_parser,
  $environment_timeout       = $::puppet::server_environment_timeout,
  $jvm_java_bin              = $::puppet::server_jvm_java_bin,
  $jvm_config                = $::puppet::server_jvm_config,
  $jvm_min_heap_size         = $::puppet::server_jvm_min_heap_size,
  $jvm_max_heap_size         = $::puppet::server_jvm_max_heap_size,
  $jvm_extra_args            = $::puppet::server_jvm_extra_args,
  $jruby_gem_home            = $::puppet::server_jruby_gem_home,
  $max_active_instances      = $::puppet::server_max_active_instances,
  $max_requests_per_instance = $::puppet::server_max_requests_per_instance,
  $use_legacy_auth_conf      = $::puppet::server_use_legacy_auth_conf,
) {

  validate_bool($ca)
  validate_bool($http)
  validate_bool($passenger)
  validate_bool($git_repo)
  validate_bool($service_fallback)
  validate_bool($server_facts)
  validate_bool($strict_variables)
  validate_bool($foreman)
  validate_bool($puppetdb_swf)
  validate_bool($default_manifest)
  validate_bool($ssl_dir_manage)
  validate_bool($passenger_pre_start)
  validate_integer($passenger_min_instances)

  validate_hash($additional_settings)

  if $default_manifest {
    validate_absolute_path($default_manifest_path)
    validate_string($default_manifest_content)
  }

  validate_string($hiera_config)
  validate_string($external_nodes)
  if $ca_proxy {
    validate_string($ca_proxy)
  }
  if $puppetdb_host {
    validate_string($puppetdb_host)
  }

  if $http {
    validate_array($http_allow)
  }

  if ! is_bool($autosign) {
    validate_absolute_path($autosign)
    validate_string($autosign_mode)
    validate_array($autosign_entries)
  }

  validate_array($rack_arguments)

  validate_re($implementation, '^(master|puppetserver)$')
  validate_re($parser, '^(current|future)$')

  if $environment_timeout {
    validate_re($environment_timeout, '^(unlimited|0|[0-9]+[smh]{1})$')
  }

  if $implementation == 'puppetserver' {
    validate_re($jvm_min_heap_size, '^[0-9]+[kKmMgG]$')
    validate_re($jvm_max_heap_size, '^[0-9]+[kKmMgG]$')
    validate_absolute_path($puppetserver_dir)
    validate_absolute_path($puppetserver_vardir)
    validate_absolute_path($jruby_gem_home)
    validate_integer($max_active_instances)
    validate_integer($max_requests_per_instance)
    validate_integer($idle_timeout)
    validate_integer($connect_timeout)
    validate_array($ssl_protocols)
    validate_array($cipher_suites)
    validate_array($ruby_load_paths)
    validate_array($ca_client_whitelist)
    validate_array($admin_api_whitelist)
    validate_bool($enable_ruby_profiler)
    validate_bool($ca_auth_required)
    validate_bool($use_legacy_auth_conf)
    validate_re($puppetserver_version, '^[\d]\.[\d]+\.[\d]+$')
  } else {
    if $ip != $puppet::params::ip {
      notify {
        'ip_not_supported':
          message  => "Bind IP address is unsupported for the ${implementation} implementation.",
          loglevel => 'warning',
      }
    }
  }

  if $ca {
    $ssl_ca_cert   = "${ssl_dir}/ca/ca_crt.pem"
    $ssl_ca_crl    = "${ssl_dir}/ca/ca_crl.pem"
    $ssl_chain     = "${ssl_dir}/ca/ca_crt.pem"
  } else {
    $ssl_ca_cert = "${ssl_dir}/certs/ca.pem"
    $ssl_ca_crl  = false
    $ssl_chain   = false
  }

  $ssl_cert      = "${ssl_dir}/certs/${certname}.pem"
  $ssl_cert_key  = "${ssl_dir}/private_keys/${certname}.pem"

  if $config_version == undef {
    if $git_repo {
      $config_version_cmd = "git --git-dir ${envs_dir}/\$environment/.git describe --all --long"
    } else {
      $config_version_cmd = undef
    }
  } else {
    $config_version_cmd = $config_version
  }

  if $implementation == 'master' {
    $pm_service = !$passenger and $service_fallback
    $ps_service = undef
  } elsif $implementation == 'puppetserver' {
    $pm_service = undef
    $ps_service = true
  }

  class { '::puppet::server::install': }~>
  class { '::puppet::server::config':  }~>
  class { '::puppet::server::service':
    puppetmaster => $pm_service,
    puppetserver => $ps_service,
  }->
  Class['puppet::server']

  Class['puppet::config'] ~> Class['puppet::server::service']
}
