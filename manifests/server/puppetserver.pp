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
  $java_bin                    = $::puppet::server::jvm_java_bin,
  $config                      = $::puppet::server::jvm_config,
  $jvm_min_heap_size           = $::puppet::server::jvm_min_heap_size,
  $jvm_max_heap_size           = $::puppet::server::jvm_max_heap_size,
  $jvm_extra_args              = $::puppet::server::jvm_extra_args,
  $server_puppetserver_dir     = $::puppet::server::puppetserver_dir,
  $server_jruby_gem_home       = $::puppet::server::jruby_gem_home,
  $server_ruby_load_paths      = $::puppet::server::ruby_load_paths,
  $server_cipher_suites        = $::puppet::server::cipher_suites,
  $server_max_active_instances = $::puppet::server::max_active_instances,
  $server_ssl_protocols        = $::puppet::server::ssl_protocols,
  $server_ca                   = $::puppet::server::ca,
  $server_dir                  = $::puppet::server::dir,
  $server_idle_timeout         = $::puppet::server::idle_timeout,
  $server_connect_timeout      = $::puppet::server::connect_timeout,
  $server_enable_ruby_profiler = $::puppet::server::enable_ruby_profiler,
  $vardir                      = $::puppet::vardir,
  $server_ca_client_whitelist  = $::puppet::server::ca_client_whitelist,
  $server_admin_api_whitelist  = $::puppet::server::admin_api_whitelist,
  $server_puppetserver_version = $::puppet::server::puppetserver_version,
  $server_use_legacy_auth_conf = $::puppet::server::use_legacy_auth_conf,
) {
  include ::puppet::server

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

  $ca_enabled_ensure = $server_ca ? {
    true    => present,
    default => absent,
  }

  $ca_disabled_ensure = $server_ca ? {
    false   => present,
    default => absent,
  }

  file_line { 'ca_enabled':
    ensure => $ca_enabled_ensure,
    path   => "${server_puppetserver_dir}/bootstrap.cfg",
    line   => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
  }

  file_line { 'ca_disabled':
    ensure => $ca_disabled_ensure,
    path   => "${server_puppetserver_dir}/bootstrap.cfg",
    line   => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
  }

  if versioncmp($server_puppetserver_version, '2.3') >= 0 {
    $versioned_code_service_ensure = present
  } else {
    $versioned_code_service_ensure = absent
  }

  file_line { 'versioned_code_service':
    ensure => $versioned_code_service_ensure,
    path   => "${server_puppetserver_dir}/bootstrap.cfg",
    line   => 'puppetlabs.services.versioned-code-service.versioned-code-service/versioned-code-service',
  }

  file { "${server_puppetserver_dir}/conf.d/ca.conf":
    ensure  => file,
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
}
