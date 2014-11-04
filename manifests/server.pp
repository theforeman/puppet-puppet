# == Class: puppet::server
#
# Sets up a puppet master.
class puppet::server {

  if $::puppet::server_ca {
    $ssl_ca_cert   = "${::puppet::server_ssl_dir}/ca/ca_crt.pem"
    $ssl_ca_crl    = "${::puppet::server_ssl_dir}/ca/ca_crl.pem"
    $ssl_chain     = "${::puppet::server_ssl_dir}/ca/ca_crt.pem"
  } else {
    $ssl_ca_cert = "${::puppet::server_ssl_dir}/certs/ca.pem"
    $ssl_ca_crl  = false
    $ssl_chain   = false
  }

  $lower_fqdn    = downcase($::fqdn)
  $ssl_cert      = "${::puppet::server_ssl_dir}/certs/${lower_fqdn}.pem"
  $ssl_cert_key  = "${::puppet::server_ssl_dir}/private_keys/${lower_fqdn}.pem"

  if $::puppet::server_config_version == undef {
    if $::puppet::server_git_repo {
      $config_version_cmd = "git --git-dir ${::puppet::server_envs_dir}/\$environment/.git describe --all --long"
    } else {
      $config_version_cmd = ''
    }
  } else {
    $config_version_cmd = $::puppet::server_config_version
  }

  if $::puppet::server_implementation == 'master' {
    $pm_service = !$::puppet::server_passenger and $::puppet::server_service_fallback
    $ps_service = undef
  } elsif $::puppet::server_implementation == 'puppetserver' {
    $pm_service = undef
    $ps_service = true
  }

  class { 'puppet::server::install': }~>
  class { 'puppet::server::config':  }~>
  class { 'puppet::server::service':
    puppetmaster => $pm_service,
    puppetserver => $ps_service,
  }->
  Class['puppet::server']

  Class['puppet::config'] ~> Class['puppet::server::service']
}
