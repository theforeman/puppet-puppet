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
    $ssl_ca_crl  = false
    $ssl_chain   = false
  }

  $ssl_cert      = "${::puppet::server_ssl_dir}/certs/${::fqdn}.pem"
  $ssl_cert_key  = "${::puppet::server_ssl_dir}/private_keys/${::fqdn}.pem"

  class { 'puppet::server::install': }~>
  class { 'puppet::server::config':  }~>
  class { 'puppet::server::service': }->
  Class['puppet::server']

  Class['puppet::config'] ~> Class['puppet::server::service']
}
