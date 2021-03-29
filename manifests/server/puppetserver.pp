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
# @example
#
#   # configure memory for java < 8
#   class {'::puppet::server::puppetserver':
#     jvm_min_heap_size => '1G',
#     jvm_max_heap_size => '3G',
#     jvm_extra_args    => '-XX:MaxPermSize=256m',
#   }
#
class puppet::server::puppetserver (
  $config                                 = $puppet::server::jvm_config,
  $java_bin                               = $puppet::server::jvm_java_bin,
  $jvm_extra_args                         = $puppet::server::real_jvm_extra_args,
  $jvm_cli_args                           = $puppet::server::jvm_cli_args,
  $jvm_min_heap_size                      = $puppet::server::jvm_min_heap_size,
  $jvm_max_heap_size                      = $puppet::server::jvm_max_heap_size,
  $server_puppetserver_dir                = $puppet::server::puppetserver_dir,
  $server_puppetserver_vardir             = $puppet::server::puppetserver_vardir,
  $server_puppetserver_rundir             = $puppet::server::puppetserver_rundir,
  $server_puppetserver_logdir             = $puppet::server::puppetserver_logdir,
  $server_jruby_gem_home                  = $puppet::server::jruby_gem_home,
  $server_ruby_load_paths                 = $puppet::server::ruby_load_paths,
  $server_cipher_suites                   = $puppet::server::cipher_suites,
  $server_max_active_instances            = $puppet::server::max_active_instances,
  $server_max_requests_per_instance       = $puppet::server::max_requests_per_instance,
  $server_max_queued_requests             = $puppet::server::max_queued_requests,
  $server_max_retry_delay                 = $puppet::server::max_retry_delay,
  $server_multithreaded                   = $puppet::server::multithreaded,
  $server_ssl_protocols                   = $puppet::server::ssl_protocols,
  $server_ssl_ca_crl                      = $puppet::server::ssl_ca_crl,
  $server_ssl_ca_cert                     = $puppet::server::ssl_ca_cert,
  $server_ssl_cert                        = $puppet::server::ssl_cert,
  $server_ssl_cert_key                    = $puppet::server::ssl_cert_key,
  $server_ssl_chain                       = $puppet::server::ssl_chain,
  $server_crl_enable                      = $puppet::server::crl_enable_real,
  $server_ip                              = $puppet::server::ip,
  $server_port                            = $puppet::server::port,
  $server_http                            = $puppet::server::http,
  $server_http_port                       = $puppet::server::http_port,
  $server_ca                              = $puppet::server::ca,
  $server_dir                             = $puppet::server::dir,
  $codedir                                = $puppet::server::codedir,
  $server_idle_timeout                    = $puppet::server::idle_timeout,
  $server_web_idle_timeout                = $puppet::server::web_idle_timeout,
  $server_connect_timeout                 = $puppet::server::connect_timeout,
  $server_ca_auth_required                = $puppet::server::ca_auth_required,
  $server_ca_client_self_delete           = $puppet::server::ca_client_self_delete,
  $server_ca_client_whitelist             = $puppet::server::ca_client_whitelist,
  $server_admin_api_whitelist             = $puppet::server::admin_api_whitelist,
  $server_puppetserver_version            = $puppet::server::real_puppetserver_version,
  $server_use_legacy_auth_conf            = $puppet::server::use_legacy_auth_conf,
  $server_check_for_updates               = $puppet::server::check_for_updates,
  $server_environment_class_cache_enabled = $puppet::server::environment_class_cache_enabled,
  $server_jruby9k                         = $puppet::server::puppetserver_jruby9k,
  $server_metrics                         = $puppet::server::puppetserver_metrics,
  $server_profiler                        = $puppet::server::puppetserver_profiler,
  $metrics_jmx_enable                     = $puppet::server::metrics_jmx_enable,
  $metrics_graphite_enable                = $puppet::server::metrics_graphite_enable,
  $metrics_graphite_host                  = $puppet::server::metrics_graphite_host,
  $metrics_graphite_port                  = $puppet::server::metrics_graphite_port,
  $metrics_server_id                      = $puppet::server::metrics_server_id,
  $metrics_graphite_interval              = $puppet::server::metrics_graphite_interval,
  $metrics_allowed                        = $puppet::server::metrics_allowed,
  $server_experimental                    = $puppet::server::puppetserver_experimental,
  $server_auth_template                   = $puppet::server::puppetserver_auth_template,
  $server_trusted_agents                  = $puppet::server::puppetserver_trusted_agents,
  $server_trusted_certificate_extensions  = $puppet::server::puppetserver_trusted_certificate_extensions,
  $allow_header_cert_info                 = $puppet::server::allow_header_cert_info,
  $compile_mode                           = $puppet::server::compile_mode,
  $acceptor_threads                       = $puppet::server::acceptor_threads,
  $selector_threads                       = $puppet::server::selector_threads,
  $ssl_acceptor_threads                   = $puppet::server::ssl_acceptor_threads,
  $ssl_selector_threads                   = $puppet::server::ssl_selector_threads,
  $max_threads                            = $puppet::server::max_threads,
  $ca_allow_sans                          = $puppet::server::ca_allow_sans,
  $ca_allow_auth_extensions               = $puppet::server::ca_allow_auth_extensions,
  $ca_enable_infra_crl                    = $puppet::server::ca_enable_infra_crl,
  $max_open_files                         = $puppet::server::max_open_files,
  $versioned_code_id                      = $puppet::server::versioned_code_id,
  $versioned_code_content                 = $puppet::server::versioned_code_content,
) {
  include puppet::server

  if versioncmp($server_puppetserver_version, '5.3.6') < 0 {
    fail('puppetserver <5.3.6 is not supported by this module version')
  }

  $puppetserver_package = pick($puppet::server::package, 'puppetserver')

  $jvm_cmd_arr = ["-Xms${jvm_min_heap_size}", "-Xmx${jvm_max_heap_size}", $jvm_extra_args]
  $jvm_cmd = strip(join(flatten($jvm_cmd_arr), ' '))

  if $facts['os']['family'] == 'FreeBSD' {
    $server_gem_paths = [ '${jruby-puppet.gem-home}', "\"${server_puppetserver_vardir}/vendored-jruby-gems\"", ] # lint:ignore:single_quote_string_with_variables
    augeas { 'puppet::server::puppetserver::jvm':
      context => '/files/etc/rc.conf',
      changes => [ "set puppetserver_java_opts '\"${jvm_cmd}\"'" ],
    }
  } else {
    if $jvm_cli_args {
      $changes = [
        "set JAVA_ARGS '\"${jvm_cmd}\"'",
        "set JAVA_BIN ${java_bin}",
        "set JAVA_ARGS_CLI '\"${jvm_cli_args}\"'",
      ]
    } else {
      $changes = [
        "set JAVA_ARGS '\"${jvm_cmd}\"'",
        "set JAVA_BIN ${java_bin}",
      ]
    }
    augeas { 'puppet::server::puppetserver::jvm':
      lens    => 'Shellvars.lns',
      incl    => $config,
      context => "/files${config}",
      changes => $changes,
    }

    $bootstrap_paths = "${server_puppetserver_dir}/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"

    $server_gem_paths = [ '${jruby-puppet.gem-home}', "\"${server_puppetserver_vardir}/vendored-jruby-gems\"", "\"/opt/puppetlabs/puppet/lib/ruby/vendor_gems\""] # lint:ignore:single_quote_string_with_variables

    augeas { 'puppet::server::puppetserver::bootstrap':
      lens    => 'Shellvars.lns',
      incl    => $config,
      context => "/files${config}",
      changes => "set BOOTSTRAP_CONFIG '\"${bootstrap_paths}\"'",
    }

    $jruby_jar_changes = $server_jruby9k ? {
      true    => "set JRUBY_JAR '\"/opt/puppetlabs/server/apps/puppetserver/jruby-9k.jar\"'",
      default => 'rm JRUBY_JAR'
    }

    augeas { 'puppet::server::puppetserver::jruby_jar':
      lens    => 'Shellvars.lns',
      incl    => $config,
      context => "/files${config}",
      changes => $jruby_jar_changes,
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

  unless $facts['os']['family'] == 'FreeBSD' {
    file { '/opt/puppetlabs/server/apps/puppetserver/config':
      ensure => directory,
    }
    file { '/opt/puppetlabs/server/apps/puppetserver/config/services.d':
      ensure => directory,
    }
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
