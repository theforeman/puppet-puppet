# == Class: puppet::server::passenger
#
# Set up the puppet server using passenger and apache.
#
class puppet::server::passenger (
  $app_root           = $::puppet::server_app_root,
  $passenger_max_pool = $::puppet::server_passenger_max_pool,
  $port               = $::puppet::server_port,
  $ssl_ca_cert        = $::puppet::server::ssl_ca_cert,
  $ssl_ca_crl         = $::puppet::server::ssl_ca_crl,
  $ssl_cert           = $::puppet::server::ssl_cert,
  $ssl_cert_key       = $::puppet::server::ssl_cert_key,
  $ssl_chain          = $::puppet::server::ssl_chain,
  $ssl_dir            = $::puppet::server_ssl_dir,
  $user               = $::puppet::server_user
) {
  include ::puppet::server::rack
  include ::apache

  case $::operatingsystem {
    Debian,Ubuntu: {
      file { '/etc/default/puppetmaster':
        content => "START=no\n",
        before  => Class['puppet::server::install'],
      }
    }
    default: {
      # nothing to do
    }
  }

  $directories = [
    {
      'path'              => "${app_root}/public/",
      'passenger_enabled' => 'On',
    },
  ]

  # The following client headers allow the same configuration to work with Pound.
  $request_headers = [
    'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
    'set X-Client-DN %{SSL_CLIENT_S_DN}e',
    'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
    'unset X-Forwarded-For',
  ]

  apache::vhost { 'puppet':
    docroot           => "${app_root}/public/",
    directories       => $directories,
    port              => $port,
    ssl               => true,
    ssl_cert          => $ssl_cert,
    ssl_key           => $ssl_cert_key,
    ssl_ca            => $ssl_ca_cert,
    ssl_crl           => $ssl_ca_crl,
    ssl_chain         => $ssl_chain,
    ssl_protocol      => '-ALL +SSLv3 +TLSv1',
    ssl_cipher        => 'ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP',
    ssl_verify_client => 'optional',
    ssl_options       => '+StdEnvVars +ExportCertData',
    ssl_verify_depth  => '1',
    request_headers   => $request_headers,
    options           => ['None'],
    require           => Class['::puppet::server::rack'],
  }

}
