# Configures the puppetserver jvm configuration file using augeas.
#
# @api private
#
# @param java_bin
#   Path to the java executable to use
#
# @param config
#   Path to the jvm configuration file.
#   This file is usually either /etc/default/puppetserver or
#   /etc/sysconfig/puppetserver depending on your *nix flavor.
#
# @param jvm_min_heap_size
#   Translates into the -Xms option and is added to the JAVA_ARGS
#
# @param jvm_max_heap_size
#   Translates into the -Xmx option and is added to the JAVA_ARGS
#
# @param jvm_extra_args
#   Custom options to pass through to the java binary. These get added to
#   the end of the JAVA_ARGS variable
#
# @param jvm_cli_args
#   Custom options to pass through to the java binary when using a
#   puppetserver subcommand, (eg puppetserver gem). These get used
#   in the JAVA_ARGS_CLI variable.
#
# @param server_puppetserver_dir
#   Puppetserver config directory
#
# @param server_puppetserver_vardir
#   Puppetserver var directory
#
# @param server_jruby_gem_home
#   Puppetserver jruby gemhome
#
# @param server_environment_vars
#   Puppetserver hash of environment vars
#
# @param server_cipher_suites
#   Puppetserver array of acceptable ciphers
#
# @param server_ssl_protocols
#   Puppetserver array of acceptable ssl protocols
#
# @param server_max_active_instances
#   Puppetserver number of max jruby instances
#
# @param server_max_requests_per_instance
#   Puppetserver number of max requests per jruby instance
#
# @param server_max_queued_requests
#   The maximum number of requests that may be queued waiting
#   to borrow a JRuby from the pool.
#
# @param server_max_retry_delay
#   Sets the upper limit for the random sleep set as a Retry-After
#   header on 503 responses returned when max-queued-requests is enabled.
#
# @param server_multithreaded
#   Configures the puppetserver to use multithreaded jruby.
#
# @param disable_fips
#   Disables FIPS support within the JVM
#
# @example configure memory for java < 8
#   class {'::puppet::server::puppetserver':
#     jvm_min_heap_size => '1G',
#     jvm_max_heap_size => '3G',
#     jvm_extra_args    => '-XX:MaxPermSize=256m',
#   }
#
class puppet::server::puppetserver (
  Optional[Pattern[/^[\d]\.[\d]+\.[\d]+$/]] $puppetserver_version = $puppet::server::puppetserver_version,
  String $config = $puppet::server::jvm_config,
  Optional[Stdlib::Absolutepath] $java_bin = $puppet::server::jvm_java_bin,
  Variant[String, Array[String]] $jvm_extra_args = $puppet::server::real_jvm_extra_args,
  Optional[String] $jvm_cli_args = $puppet::server::jvm_cli_args,
  Pattern[/^[0-9]+[kKmMgG]$/] $jvm_min_heap_size = $puppet::server::jvm_min_heap_size,
  Pattern[/^[0-9]+[kKmMgG]$/] $jvm_max_heap_size = $puppet::server::jvm_max_heap_size,
  Stdlib::Absolutepath $server_puppetserver_dir = $puppet::server::puppetserver_dir,
  Stdlib::Absolutepath $server_puppetserver_vardir = $puppet::server::puppetserver_vardir,
  Optional[Stdlib::Absolutepath] $server_puppetserver_rundir = $puppet::server::puppetserver_rundir,
  Optional[Stdlib::Absolutepath] $server_puppetserver_logdir = $puppet::server::puppetserver_logdir,
  Optional[Stdlib::Absolutepath] $server_jruby_gem_home = $puppet::server::jruby_gem_home,
  Hash[String, String] $server_environment_vars = $puppet::server::server_environment_vars,
  Array[String] $server_ruby_load_paths = $puppet::server::ruby_load_paths,
  Array[String] $server_cipher_suites = $puppet::server::cipher_suites,
  Integer[1] $server_max_active_instances = $puppet::server::max_active_instances,
  Integer[0] $server_max_requests_per_instance = $puppet::server::max_requests_per_instance,
  Integer[0] $server_max_queued_requests = $puppet::server::max_queued_requests,
  Integer[0] $server_max_retry_delay = $puppet::server::max_retry_delay,
  Boolean $server_multithreaded = $puppet::server::multithreaded,
  Array[String] $server_ssl_protocols = $puppet::server::ssl_protocols,
  Stdlib::Absolutepath $server_ssl_ca_crl = $puppet::server::ssl_ca_crl,
  Stdlib::Absolutepath $server_ssl_ca_cert = $puppet::server::ssl_ca_cert,
  Stdlib::Absolutepath $server_ssl_cert = $puppet::server::ssl_cert,
  Stdlib::Absolutepath $server_ssl_cert_key = $puppet::server::ssl_cert_key,
  Variant[Boolean, Stdlib::Absolutepath] $server_ssl_chain = $puppet::server::ssl_chain,
  Boolean $server_crl_enable = $puppet::server::crl_enable_real,
  String $server_ip = $puppet::server::ip,
  Stdlib::Port $server_port = $puppet::server::port,
  Boolean $server_http = $puppet::server::http,
  Stdlib::Port $server_http_port = $puppet::server::http_port,
  Boolean $server_ca = $puppet::server::ca,
  String $server_dir = $puppet::server::dir,
  Stdlib::Absolutepath $codedir = $puppet::server::codedir,
  Integer[0] $server_idle_timeout = $puppet::server::idle_timeout,
  Integer[0] $server_web_idle_timeout = $puppet::server::web_idle_timeout,
  Integer[0] $server_connect_timeout = $puppet::server::connect_timeout,
  Boolean $server_ca_auth_required = $puppet::server::ca_auth_required,
  Boolean $server_ca_client_self_delete = $puppet::server::ca_client_self_delete,
  Array[String] $server_ca_client_allowlist = $puppet::server::ca_client_allowlist,
  Array[String] $server_admin_api_allowlist = $puppet::server::admin_api_allowlist,
  Boolean $server_check_for_updates = $puppet::server::check_for_updates,
  Boolean $server_environment_class_cache_enabled = $puppet::server::environment_class_cache_enabled,
  Optional[Boolean] $server_metrics = $puppet::server::puppetserver_metrics,
  Boolean $server_profiler = $puppet::server::puppetserver_profiler,
  Boolean $server_telemetry = pick($puppet::server::puppetserver_telemetry, false),
  Boolean $metrics_jmx_enable = $puppet::server::metrics_jmx_enable,
  Boolean $metrics_graphite_enable = $puppet::server::metrics_graphite_enable,
  String $metrics_graphite_host = $puppet::server::metrics_graphite_host,
  Stdlib::Port $metrics_graphite_port = $puppet::server::metrics_graphite_port,
  String $metrics_server_id = $puppet::server::metrics_server_id,
  Integer $metrics_graphite_interval = $puppet::server::metrics_graphite_interval,
  Optional[Array] $metrics_allowed = $puppet::server::metrics_allowed,
  Boolean $server_experimental = $puppet::server::puppetserver_experimental,
  Optional[String[1]] $server_auth_template = $puppet::server::puppetserver_auth_template,
  Array[String] $server_trusted_agents = $puppet::server::puppetserver_trusted_agents,
  Array[Hash] $server_trusted_certificate_extensions = $puppet::server::puppetserver_trusted_certificate_extensions,
  Boolean $allow_header_cert_info = $puppet::server::allow_header_cert_info,
  Optional[Enum['off', 'jit', 'force']] $compile_mode = $puppet::server::compile_mode,
  Optional[Integer[1]] $acceptor_threads = $puppet::server::acceptor_threads,
  Optional[Integer[1]] $selector_threads = $puppet::server::selector_threads,
  Optional[Integer[1]] $ssl_acceptor_threads = $puppet::server::ssl_acceptor_threads,
  Optional[Integer[1]] $ssl_selector_threads = $puppet::server::ssl_selector_threads,
  Optional[Integer[1]] $max_threads = $puppet::server::max_threads,
  Boolean $ca_allow_sans = $puppet::server::ca_allow_sans,
  Boolean $ca_allow_auth_extensions = $puppet::server::ca_allow_auth_extensions,
  Boolean $ca_enable_infra_crl = $puppet::server::ca_enable_infra_crl,
  Boolean $server_ca_allow_auto_renewal = $puppet::server::server_ca_allow_auto_renewal,
  String $server_ca_allow_auto_renewal_cert_ttl = $puppet::server::server_ca_allow_auto_renewal_cert_ttl,
  Optional[Integer[1]] $max_open_files = $puppet::server::max_open_files,
  Optional[Stdlib::Absolutepath] $versioned_code_id = $puppet::server::versioned_code_id,
  Optional[Stdlib::Absolutepath] $versioned_code_content = $puppet::server::versioned_code_content,
  Boolean $disable_fips = $facts['os']['family'] == 'RedHat',
  Array[String[1]] $jolokia_metrics_allowlist = $puppet::server::jolokia_metrics_allowlist,
) {
  include puppet::server

  # For Puppetserver, certain configuration parameters are version specific.
  # We need a method to determine what version is installed.
  if $puppetserver_version {
    $real_puppetserver_version = $puppetserver_version
  } elsif versioncmp($facts['puppetversion'], '8.0.0') >= 0 {
    $real_puppetserver_version = '8.0.0'
  } else {
    # our minimum supported version of puppet server
    $real_puppetserver_version = '8.0.0'
  }

  $puppetserver_package = pick($puppet::server::package, 'puppetserver')

  if $java_bin {
    $_java_bin = $java_bin
  } elsif versioncmp($real_puppetserver_version, '8.0.0') >= 0 {
    # Follows logic that https://github.com/puppetlabs/ezbake/pull/627 suggests, but takes it a
    # step further by also ensuring EL 8 has Java 17
    $_java_bin = case $facts['os']['family'] {
      'RedHat': {
        $facts['os']['release']['major'] ? {
          /^([89])$/ => '/usr/lib/jvm/jre-17/bin/java',
          default    => '/usr/bin/java'
        }
      }
      default: {
        '/usr/bin/java'
      }
    }
  } else {
    $_java_bin = '/usr/bin/java'
  }

  $jvm_heap_arr = ["-Xms${jvm_min_heap_size}", "-Xmx${jvm_max_heap_size}"]
  if $disable_fips {
    $jvm_cmd_arr = $jvm_heap_arr + ['-Dcom.redhat.fips=false', $jvm_extra_args]
  } else {
    $jvm_cmd_arr = $jvm_heap_arr + [$jvm_extra_args]
  }
  $jvm_cmd = strip(join(flatten($jvm_cmd_arr), ' '))

  if $facts['os']['family'] == 'FreeBSD' {
    $server_gem_paths = ['${jruby-puppet.gem-home}', "\"${server_puppetserver_vardir}/vendored-jruby-gems\"", sprintf('"%s"', regsubst($facts['ruby']['sitedir'], 'site_ruby', 'gems'))] # lint:ignore:single_quote_string_with_variables
    augeas { 'puppet::server::puppetserver::jvm':
      context => '/files/etc/rc.conf',
      changes => ["set puppetserver_java_opts '\"${jvm_cmd}\"'"],
    }
  } elsif $facts['os']['family'] == 'Debian' and !$puppet::params::aio_package {
    $server_gem_paths = ['${jruby-puppet.gem-home}', '/usr/lib/puppetserver/vendored-jruby-gems'] # lint:ignore:single_quote_string_with_variables
  } else {
    if $jvm_cli_args {
      $changes = [
        "set JAVA_ARGS '\"${jvm_cmd}\"'",
        "set JAVA_BIN ${_java_bin}",
        "set JAVA_ARGS_CLI '\"${jvm_cli_args}\"'",
      ]
    } else {
      $changes = [
        "set JAVA_ARGS '\"${jvm_cmd}\"'",
        "set JAVA_BIN ${_java_bin}",
      ]
    }
    augeas { 'puppet::server::puppetserver::jvm':
      lens    => 'Shellvars.lns',
      incl    => $config,
      context => "/files${config}",
      changes => $changes,
    }

    $bootstrap_paths = "${server_puppetserver_dir}/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"

    $server_gem_paths = ['${jruby-puppet.gem-home}', "\"${server_puppetserver_vardir}/vendored-jruby-gems\"", "\"/opt/puppetlabs/puppet/lib/ruby/vendor_gems\""] # lint:ignore:single_quote_string_with_variables

    augeas { 'puppet::server::puppetserver::bootstrap':
      lens    => 'Shellvars.lns',
      incl    => $config,
      context => "/files${config}",
      changes => "set BOOTSTRAP_CONFIG '\"${bootstrap_paths}\"'",
    }

    augeas { 'puppet::server::puppetserver::jruby_jar':
      lens    => 'Shellvars.lns',
      incl    => $config,
      context => "/files${config}",
      changes => 'rm JRUBY_JAR',
    }

    $ensure_max_open_files = $max_open_files ? {
      undef   => 'absent',
      default => 'present',
    }
    if $facts['service_provider'] == 'systemd' {
      systemd::dropin_file { 'puppetserver.service-limits.conf':
        ensure   => $ensure_max_open_files,
        filename => 'limits.conf',
        unit     => 'puppetserver.service',
        content  => "[Service]\nLimitNOFILE=${max_open_files}\n",
      }

      # https://github.com/puppetlabs/ezbake/pull/623
      systemd::dropin_file { 'puppetserver.service-privatetmp.conf':
        ensure   => present,
        filename => 'privatetmp.conf',
        unit     => 'puppetserver.service',
        content  => "[Service]\nPrivateTmp=true\n",
      }
    } else {
      file_line { 'puppet::server::puppetserver::max_open_files':
        ensure => $ensure_max_open_files,
        path   => $config,
        line   => "ulimit -n ${max_open_files}",
        match  => '^ulimit\ -n',
      }
    }
  }

  $servicesd = "${server_puppetserver_dir}/services.d"
  file { $servicesd:
    ensure => directory,
  }
  file { "${servicesd}/ca.cfg":
    ensure  => file,
    content => template('puppet/server/puppetserver/services.d/ca.cfg.erb'),
  }

  file { "${server_puppetserver_dir}/conf.d/ca.conf":
    ensure  => file,
    content => template('puppet/server/puppetserver/conf.d/ca.conf.erb'),
  }

  file { "${server_puppetserver_dir}/conf.d/puppetserver.conf":
    ensure  => file,
    content => template('puppet/server/puppetserver/conf.d/puppetserver.conf.erb'),
  }

  $auth_template = pick($server_auth_template, 'puppet/server/puppetserver/conf.d/auth.conf.erb')
  file { "${server_puppetserver_dir}/conf.d/auth.conf":
    ensure  => file,
    content => template($auth_template),
  }

  file { "${server_puppetserver_dir}/conf.d/webserver.conf":
    ensure  => file,
    content => template('puppet/server/puppetserver/conf.d/webserver.conf.erb'),
  }

  file { "${server_puppetserver_dir}/conf.d/product.conf":
    ensure  => file,
    content => template('puppet/server/puppetserver/conf.d/product.conf.erb'),
  }

  file { "${server_puppetserver_dir}/conf.d/metrics.conf":
    ensure  => 'file',
    content => template('puppet/server/puppetserver/conf.d/metrics.conf.erb'),
  }
}
