# == Class: puppet::server::passenger
#
# Set up the puppet server using passenger and apache.
#
class puppet::server::passenger {
  include ::puppet::server::rack
  include ::apache
  include ::passenger
  include ::apache::mod::headers

  # mirror 'external' params here for easy use in templates.

  $ssl_dir      = $::puppet::server_ssl_dir
  $ssl_cert     = $::puppet::server::ssl_cert
  $ssl_cert_key = $::puppet::server::ssl_cert_key
  $ssl_ca_cert  = $::puppet::server::ssl_ca_cert
  # We check to surpress some warnings.
  if $::puppet::server_ca {
    $ssl_chain    = $::puppet::server::ssl_chain
    $ssl_ca_crl   = $::puppet::server::ssl_ca_crl
  } else {
    $ssl_chain    = false
    $ssl_ca_crl   = false
  }

  $port               = $::puppet::server_port
  $user               = $::puppet::server_user
  $app_root           = $::puppet::server_app_root
  $passenger_max_pool = $::puppet::server_passenger_max_pool

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

  apache::vhost {'puppet':
    docroot         => "${app_root}/public/",
    directories     => $directories,
    port            => $port,
    ssl             => true,
    ssl_cert        => $ssl_cert,
    ssl_key         => $ssl_cert_key,
    ssl_ca          => $ssl_ca_cert,
    ssl_crl         => $ssl_ca_crl,
    ssl_chain       => $ssl_chain,
    options         => ['None'],
    custom_fragment => template('puppet/server/puppet-vhost-fragment.erb'),
    require         => Class['::puppet::server::rack'],
  }

}
