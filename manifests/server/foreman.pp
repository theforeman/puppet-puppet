# @summary Set up Foreman integration
# @api private
class puppet::server::foreman {
  # Include foreman components for the puppetmaster
  # ENC script, reporting script etc.
  class { 'puppetserver_foreman':
    foreman_url      => $puppet::server::foreman_url,
    enc_upload_facts => $puppet::server::server_foreman_facts,
    enc_timeout      => $puppet::server::request_timeout,
    puppet_home      => $puppet::server::puppetserver_vardir,
    puppet_basedir   => $puppet::server::puppet_basedir,
    puppet_etcdir    => $puppet::dir,
    ssl_ca           => pick($puppet::server::foreman_ssl_ca, $puppet::server::ssl_ca_cert),
    ssl_cert         => pick($puppet::server::foreman_ssl_cert, $puppet::server::ssl_cert),
    ssl_key          => pick($puppet::server::foreman_ssl_key, $puppet::server::ssl_cert_key),
  }
  contain puppetserver_foreman
}
