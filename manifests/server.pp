# == Class: puppet::server
#
# Sets up a puppet master.
class puppet::server {

  if $::puppet::server_passenger or ($::puppet::server_service_fallback == false) {
    $use_service = false
  } else {
    $use_service = true
  }

  if $::puppet::server_ca {
    $ssl_ca_cert   = "${::puppet::server_ssl_dir}/ca/ca_crt.pem"
    $ssl_ca_crl    = "${::puppet::server_ssl_dir}/ca/ca_crl.pem"
    $ssl_chain     = "${::puppet::server_ssl_dir}/ca/ca_crt.pem"
  } else {
    $ssl_ca_cert = "${::puppet::server_ssl_dir}/certs/ca.pem"
  }

  $ssl_cert      = "${::puppet::server_ssl_dir}/certs/${::fqdn}.pem"
  $ssl_cert_key  = "${::puppet::server_ssl_dir}/private_keys/${::fqdn}.pem"

  if $::puppet::server_config_version == undef {
    if $::puppet::server_git_repo {
      $config_version_cmd = "git --git-dir ${::puppet::server_envs_dir}/\$environment/.git describe --all --long"
    } else {
      $config_version_cmd = ''
    }
  } else {
    $config_version_cmd = $::puppet::server_config_version
  }

  class { 'puppet::server::install': }~>
  class { 'puppet::server::config':  }~>
  class { 'puppet::server::service': }->
  Class['puppet::server']

}
