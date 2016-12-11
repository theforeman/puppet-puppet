# == Class: puppet::server::puppetserver
#
# Configures the puppetserver jvm configuration file using augeas.
#
# === Parameters:
#
# * `java_bin`
# Path to the java executable to use
#
# * `config`
# Path to the jvm configuration file.
# This file is usually either /etc/default/puppetserver or
# /etc/sysconfig/puppetserver depending on your *nix flavor.
#
# * `jvm_min_heap_size`
# Translates into the -Xms option and is added to the JAVA_ARGS
#
# * `jvm_max_heap_size`
# Translates into the -Xmx option and is added to the JAVA_ARGS
#
# * `jvm_extra_args`
# Custom options to pass through to the java binary. These get added to
# the end of the JAVA_ARGS variable
#
# * `server_puppetserver_dir`
# Puppetserver config directory
#
# * `server_puppetserver_vardir`
# Puppetserver var directory
#
# * `server_jruby_gem_home`
# Puppetserver jruby gemhome
#
# * `server_cipher_suites`
# Puppetserver array of acceptable ciphers
#
# * `server_ssl_protocols`
# Puppetserver array of acceptable ssl protocols
#
# * `server_max_active_instances`
# Puppetserver number of max jruby instances
#
# * `server_max_requests_per_instance`
# Puppetserver number of max requests per jruby instance
#
# === Example
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
  $config                                 = $::puppet::server::jvm_config,
  $java_bin                               = $::puppet::server::jvm_java_bin,
  $jvm_extra_args                         = $::puppet::server::jvm_extra_args,
  $jvm_min_heap_size                      = $::puppet::server::jvm_min_heap_size,
  $jvm_max_heap_size                      = $::puppet::server::jvm_max_heap_size,
  $server_puppetserver_dir                = $::puppet::server::puppetserver_dir,
  $server_puppetserver_vardir             = $::puppet::server::puppetserver_vardir,
  $server_puppetserver_rundir             = $::puppet::server::puppetserver_rundir,
  $server_puppetserver_logdir             = $::puppet::server::puppetserver_logdir,
  $server_jruby_gem_home                  = $::puppet::server::jruby_gem_home,
  $server_ruby_load_paths                 = $::puppet::server::ruby_load_paths,
  $server_cipher_suites                   = $::puppet::server::cipher_suites,
  $server_max_active_instances            = $::puppet::server::max_active_instances,
  $server_max_requests_per_instance       = $::puppet::server::max_requests_per_instance,
  $server_ssl_protocols                   = $::puppet::server::ssl_protocols,
  $server_http                            = $::puppet::server::http,
  $server_http_allow                      = $::puppet::server::http_allow,
  $server_ca                              = $::puppet::server::ca,
  $server_dir                             = $::puppet::server::dir,
  $codedir                                = $::puppet::server::codedir,
  $server_idle_timeout                    = $::puppet::server::idle_timeout,
  $server_connect_timeout                 = $::puppet::server::connect_timeout,
  $server_enable_ruby_profiler            = $::puppet::server::enable_ruby_profiler,
  $server_ca_auth_required                = $::puppet::server::ca_auth_required,
  $server_ca_client_whitelist             = $::puppet::server::ca_client_whitelist,
  $server_admin_api_whitelist             = $::puppet::server::admin_api_whitelist,
  $server_puppetserver_version            = $::puppet::server::puppetserver_version,
  $server_use_legacy_auth_conf            = $::puppet::server::use_legacy_auth_conf,
  $server_check_for_updates               = $::puppet::server::check_for_updates,
  $server_environment_class_cache_enabled = $::puppet::server::environment_class_cache_enabled,
) {
  include ::puppet::server

  if !(empty($server_http_allow)) {
    fail('setting $server_http_allow is not supported for puppetserver as it would have no effect')
  }

  $puppetserver_package = pick($::puppet::server::package, 'puppetserver')

  $jvm_cmd_arr = ["-Xms${jvm_min_heap_size}", "-Xmx${jvm_max_heap_size}", $jvm_extra_args]
  $jvm_cmd = strip(join(flatten($jvm_cmd_arr),' '))

  augeas { 'puppet::server::puppetserver::jvm':
    lens    => 'Shellvars.lns',
    incl    => $config,
    context => "/files${config}",
    changes => [
      "set JAVA_ARGS '\"${jvm_cmd}\"'",
      "set JAVA_BIN ${java_bin}",
    ],
  }

  if versioncmp($server_puppetserver_version, '2.4.99') == 0 {
    $bootstrap_paths = "${server_puppetserver_dir}/bootstrap.cfg,${server_puppetserver_dir}/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"
  } elsif versioncmp($server_puppetserver_version, '2.5') >= 0 {
    $bootstrap_paths = "${server_puppetserver_dir}/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"
  } else {  # 2.4
    $bootstrap_paths = "${server_puppetserver_dir}/bootstrap.cfg"
  }
  augeas { 'puppet::server::puppetserver::bootstrap':
    lens    => 'Shellvars.lns',
    incl    => $config,
    context => "/files${config}",
    changes => "set BOOTSTRAP_CONFIG '\"${bootstrap_paths}\"'",
  }

  # 2.4.99 configures for both 2.4 and 2.5 making upgrades and new installations easier when the
  # precise version available isn't known
  if versioncmp($server_puppetserver_version, '2.4.99') >= 0 {
    $servicesd = "${server_puppetserver_dir}/services.d"
    file { $servicesd:
      ensure => directory,
    }
    file { "${servicesd}/ca.cfg":
      ensure  => file,
      content => template('puppet/server/puppetserver/services.d/ca.cfg.erb'),
    }

    file { '/opt/puppetlabs/server/apps/puppetserver/config':
      ensure => directory,
    }
    file { '/opt/puppetlabs/server/apps/puppetserver/config/services.d':
      ensure => directory,
    }
  }

  if versioncmp($server_puppetserver_version, '2.5') < 0 {
    $bootstrapcfg = "${server_puppetserver_dir}/bootstrap.cfg"
    file { $bootstrapcfg:
      ensure => file,
    }

    $ca_enabled_ensure = $server_ca ? {
      true    => present,
      default => absent,
    }

    $ca_disabled_ensure = $server_ca ? {
      false   => present,
      default => absent,
    }

    file_line { 'ca_enabled':
      ensure  => $ca_enabled_ensure,
      path    => $bootstrapcfg,
      line    => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
      require => File[$bootstrapcfg],
    }

    file_line { 'ca_disabled':
      ensure  => $ca_disabled_ensure,
      path    => $bootstrapcfg,
      line    => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
      require => File[$bootstrapcfg],
    }

    if versioncmp($server_puppetserver_version, '2.3') >= 0 {
      $versioned_code_service_ensure = present
    } else {
      $versioned_code_service_ensure = absent
    }

    file_line { 'versioned_code_service':
      ensure  => $versioned_code_service_ensure,
      path    => $bootstrapcfg,
      line    => 'puppetlabs.services.versioned-code-service.versioned-code-service/versioned-code-service',
      require => File[$bootstrapcfg],
    }
  }

  if versioncmp($server_puppetserver_version, '2.2') < 0 {
    $ca_conf_ensure = file
  } else {
    $ca_conf_ensure = absent
  }

  file { "${server_puppetserver_dir}/conf.d/ca.conf":
    ensure  => $ca_conf_ensure,
    content => template('puppet/server/puppetserver/conf.d/ca.conf.erb'),
  }

  file { "${server_puppetserver_dir}/conf.d/puppetserver.conf":
    ensure  => file,
    content => template('puppet/server/puppetserver/conf.d/puppetserver.conf.erb'),
  }

  file { "${server_puppetserver_dir}/conf.d/web-routes.conf":
    ensure  => file,
    content => template('puppet/server/puppetserver/conf.d/web-routes.conf.erb'),
  }

  file { "${server_puppetserver_dir}/conf.d/webserver.conf":
    ensure  => file,
    content => template('puppet/server/puppetserver/conf.d/webserver.conf.erb'),
  }

  file { "${server_puppetserver_dir}/conf.d/auth.conf":
    ensure  => file,
    content => template('puppet/server/puppetserver/conf.d/auth.conf.erb'),
  }

  if versioncmp($server_puppetserver_version, '2.7') >= 0 {
    $product_conf_ensure = file
  } else {
    $product_conf_ensure = absent
  }

  file { "${server_puppetserver_dir}/conf.d/product.conf":
    ensure  => $product_conf_ensure,
    content => template('puppet/server/puppetserver/conf.d/product.conf.erb'),
  }
}
