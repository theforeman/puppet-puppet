# == Class: puppet::server
#
# Sets up a puppet master.
class puppet::server(
  $autosign                 = $::puppet::autosign,
  $autosign_mode            = $::puppet::autosign_mode,
  $hiera_config             = $::puppet::hiera_config,
  $admin_api_whitelist      = $::puppet::server_admin_api_whitelist,
  $user                     = $::puppet::server_user,
  $group                    = $::puppet::server_group,
  $dir                      = $::puppet::server_dir,
  $port                     = $::puppet::server_port,
  $ip                       = $::puppet::server_ip,
  $ca                       = $::puppet::server_ca,
  $ca_auth_required         = $::puppet::server_ca_auth_required,
  $ca_client_whitelist      = $::puppet::server_ca_client_whitelist,
  $http                     = $::puppet::server_http,
  $http_port                = $::puppet::server_http_port,
  $http_allow               = $::puppet::server_http_allow,
  $reports                  = $::puppet::server_reports,
  $implementation           = $::puppet::server_implementation,
  $passenger                = $::puppet::server_passenger,
  $puppetserver_dir         = $::puppet::server_puppetserver_dir,
  $puppetserver_version     = $::puppet::server_puppetserver_version,
  $service_fallback         = $::puppet::server_service_fallback,
  $passenger_min_instances  = $::puppet::server_passenger_min_instances,
  $passenger_pre_start      = $::puppet::server_passenger_pre_start,
  $httpd_service            = $::puppet::server_httpd_service,
  $external_nodes           = $::puppet::server_external_nodes,
  $template                 = $::puppet::server_template,
  $main_template            = $::puppet::server_main_template,
  $cipher_suites            = $::puppet::server_cipher_suites,
  $config_version           = $::puppet::server_config_version,
  $connect_timeout          = $::puppet::server_connect_timeout,
  $git_repo                 = $::puppet::server_git_repo,
  $dynamic_environments     = $::puppet::server_dynamic_environments,
  $directory_environments   = $::puppet::server_directory_environments,
  $default_manifest         = $::puppet::server_default_manifest,
  $default_manifest_path    = $::puppet::server_default_manifest_path,
  $default_manifest_content = $::puppet::server_default_manifest_content,
  $enable_ruby_profiler     = $::puppet::server_enable_ruby_profiler,
  $environments             = $::puppet::server_environments,
  $environments_owner       = $::puppet::server_environments_owner,
  $environments_group       = $::puppet::server_environments_group,
  $environments_mode        = $::puppet::server_environments_mode,
  $envs_dir                 = $::puppet::server_envs_dir,
  $manifest_path            = $::puppet::server_manifest_path,
  $common_modules_path      = $::puppet::server_common_modules_path,
  $git_repo_mode            = $::puppet::server_git_repo_mode,
  $git_repo_path            = $::puppet::server_git_repo_path,
  $git_repo_group           = $::puppet::server_git_repo_group,
  $git_repo_user            = $::puppet::server_git_repo_user,
  $git_branch_map           = $::puppet::server_git_branch_map,
  $idle_timeout             = $::puppet::server_idle_timeout,
  $post_hook_content        = $::puppet::server_post_hook_content,
  $post_hook_name           = $::puppet::server_post_hook_name,
  $storeconfigs_backend     = $::puppet::server_storeconfigs_backend,
  $app_root                 = $::puppet::server_app_root,
  $ruby_load_paths          = $::puppet::server_ruby_load_paths,
  $ssl_dir                  = $::puppet::server_ssl_dir,
  $ssl_dir_manage           = $::puppet::server_ssl_dir_manage,
  $ssl_protocols            = $::puppet::server_ssl_protocols,
  $package                  = $::puppet::server_package,
  $version                  = $::puppet::server_version,
  $certname                 = $::puppet::server_certname,
  $enc_api                  = $::puppet::server_enc_api,
  $report_api               = $::puppet::server_report_api,
  $request_timeout          = $::puppet::server_request_timeout,
  $ca_proxy                 = $::puppet::server_ca_proxy,
  $strict_variables         = $::puppet::server_strict_variables,
  $additional_settings      = $::puppet::server_additional_settings,
  $rack_arguments           = $::puppet::server_rack_arguments,
  $foreman                  = $::puppet::server_foreman,
  $foreman_url              = $::puppet::server_foreman_url,
  $foreman_ssl_ca           = $::puppet::server_foreman_ssl_ca,
  $foreman_ssl_cert         = $::puppet::server_foreman_ssl_cert,
  $foreman_ssl_key          = $::puppet::server_foreman_ssl_key,
  $server_facts             = $::puppet::server_facts,
  $puppet_basedir           = $::puppet::server_puppet_basedir,
  $puppetdb_host            = $::puppet::server_puppetdb_host,
  $puppetdb_port            = $::puppet::server_puppetdb_port,
  $puppetdb_swf             = $::puppet::server_puppetdb_swf,
  $parser                   = $::puppet::server_parser,
  $environment_timeout      = $::puppet::server_environment_timeout,
  $jvm_java_bin             = $::puppet::server_jvm_java_bin,
  $jvm_config               = $::puppet::server_jvm_config,
  $jvm_min_heap_size        = $::puppet::server_jvm_min_heap_size,
  $jvm_max_heap_size        = $::puppet::server_jvm_max_heap_size,
  $jvm_extra_args           = $::puppet::server_jvm_extra_args,
  $jruby_gem_home           = $::puppet::server_jruby_gem_home,
  $max_active_instances     = $::puppet::server_max_active_instances,
  $use_legacy_auth_conf     = $::puppet::server_use_legacy_auth_conf,
) {

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
