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
  $user               = $::puppet::server_user,
  $http               = $::puppet::server_http,
  $http_port          = $::puppet::server_http_port,
  $http_allow         = $::puppet::server_http_allow,
) {
  include ::apache
  include ::apache::mod::passenger

  class { '::puppet::server::rack':
    app_root => $app_root,
    user     => $user,
  }

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

  $directory = {
    'path'              => "${app_root}/public/",
    'passenger_enabled' => 'On',
  }
  
  $directories = [
    $directory,
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

  if $http {
    # Order, deny and allow cannot be configured for Apache >= 2.4 using the Puppetlabs/Apache
    # module, but they can be set to false. So, set to false and configure manually via custom fragments.
    # We can't get rid of the 'Order allow,deny' directive and we need to support all Apache versions.
    # Best we can do is reverse the Order directive and add our own 'Deny from all' for good measure.
    $directories_http = [
      merge($directory, {
        'order'           => false,
        'deny'            => false,
        'allow'           => false,
        'custom_fragment' => join([
            'Order deny,allow',
            'Deny from all',
            inline_template("<%- if @http_allow and Array(@http_allow).join(' ') != '' -%>Allow from <%= @http_allow.join(' ') %><%- end -%>"),
          ], "\n")
      }),
    ]
    
    apache::vhost { 'puppet-http':
      docroot         => "${app_root}/public/",
      directories     => $directories_http,
      port            => $http_port,
      custom_fragment => join([
          $custom_fragment ? {
            undef   => '',
            default => $custom_fragment
          },
          'SetEnvIf X-Client-Verify "(.*)" SSL_CLIENT_VERIFY=$1',
          'SetEnvIf X-SSL-Client-DN "(.*)" SSL_CLIENT_S_DN=$1',
        ], "\n"),
      options         => ['None'],
      require         => Class['::puppet::server::rack'],
    }
  }
}
