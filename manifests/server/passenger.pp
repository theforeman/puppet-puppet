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
  $puppet_ca_proxy    = $::puppet::server_ca_proxy,
  $user               = $::puppet::server_user
) {
  include ::puppet::server::rack
  include ::apache
  include ::apache::mod::passenger

  case $::operatingsystem {
    'Debian', 'Ubuntu': {
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

  if $puppet_ca_proxy and $puppet_ca_proxy != '' {
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http

    $custom_fragment = "ProxyPassMatch ^/([^/]+/certificate.*)$ ${puppet_ca_proxy}/\$1"
    $ssl_proxyengine = true
  } else {
    $custom_fragment = undef
    $ssl_proxyengine = false
  }

  $ssl_crl_check = $ssl_ca_crl ? {
    false   => undef,
    undef   => undef,
    default => 'chain',
  }

  apache::vhost { 'puppet':
    docroot              => "${app_root}/public/",
    directories          => $directories,
    port                 => $port,
    ssl                  => true,
    ssl_cert             => $ssl_cert,
    ssl_key              => $ssl_cert_key,
    ssl_ca               => $ssl_ca_cert,
    ssl_crl              => $ssl_ca_crl,
    ssl_crl_check        => $ssl_crl_check,
    ssl_chain            => $ssl_chain,
    ssl_protocol         => 'ALL -SSLv2 -SSLv3',
    ssl_cipher           => 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA',
    ssl_honorcipherorder => 'on',
    ssl_verify_client    => 'optional',
    ssl_options          => '+StdEnvVars +ExportCertData',
    ssl_verify_depth     => '1',
    ssl_proxyengine      => $ssl_proxyengine,
    custom_fragment      => $custom_fragment,
    request_headers      => $request_headers,
    options              => ['None'],
    require              => Class['::puppet::server::rack'],
  }

}
