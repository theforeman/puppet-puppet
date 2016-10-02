# == Class: puppet::server::reverseproxy
#
# Set up apache to proxy certificate requests to the
# designated ca server.
#
class puppet::server::reverseproxy (
  $port                  = $::puppet::server::port,
  $ssl_ca_cert           = $::puppet::server::ssl_ca_cert,
  $ssl_ca_crl            = $::puppet::server::ssl_ca_crl,
  $ssl_cert              = $::puppet::server::ssl_cert,
  $ssl_cert_key          = $::puppet::server::ssl_cert_key,
  $ssl_chain             = $::puppet::server::ssl_chain,
  $ssl_dir               = $::puppet::server::ssl_dir,
  $http                  = $::puppet::server::http,
  $http_port             = $::puppet::server::http_port,
  $confdir               = $::puppet::server::dir,
  $ca_port               = $::puppet::ca_port,
  $ca_server             = $::puppet::ca_server,
  $vardir                = $::puppet::vardir
) {
  include ::apache
  file { "$confdir/public":
    ensure => directory,
  }
 
  ::apache::listen {'8140':}
 
  ::apache::vhost { 'puppetserver-reverse-proxy':
    servername           => "$fqdn",
    vhost_name           => '*',
    priority             => false,
    docroot              => "$confdir/public",
    port                 => $port,
    ssl                  => true,
    ssl_cert             => $ssl_cert,
    ssl_key              => $ssl_cert_key,
    ssl_ca               => $ssl_ca_cert,
    ssl_crl              => $ssl_ca_crl,
    ssl_chain            => $ssl_chain,
    ssl_protocol         => 'ALL -SSLv2 -SSLv3',
    ssl_cipher           => 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA',
    ssl_honorcipherorder => 'on',
    ssl_verify_client    => 'optional',
    ssl_options          => '+StdEnvVars +ExportCertData',
    ssl_verify_depth     => '1',
    ssl_proxyengine      => true,
    proxy_preserve_host  => true,
    request_headers      => [
      'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
      'set X-Client-DN %{SSL_CLIENT_S_DN}e',
      'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
    ],
    proxy_pass_match     => [
      {
          'path'         => '^/.*/certificate.*/',
          'url'          => "https://${ca_server}:${ca_port}",
          'reverse_urls' => "https://${ca_server}:${ca_port}",
      },
      {
          'path'         => '/',
          'url'          => "http://localhost:${http_port}",
          'reverse_urls' => "http://localhost:${http_port}",
      },
    ],
    require              => File["$confdir/public"],
  }
}
