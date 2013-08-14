# == Class: puppet::server::passenger
#
# Set up the puppet server using passenger and apache.
#
class puppet::server::passenger {

  include ::puppet::server::rack
  include ::apache::ssl
  include ::apache::params
  include ::passenger

  # mirror 'external' params here for easy use in templates.

  $ssl_dir      = $::puppet::server_ssl_dir
  $ssl_cert     = $::puppet::server::ssl_cert
  $ssl_cert_key = $::puppet::server::ssl_cert_key
  $ssl_ca_cert  = $::puppet::server::ssl_ca_cert
  # We check to surpress some warnings.
  if $::puppet::server_ca {
    $ssl_chain    = $::puppet::server::ssl_chain
    $ssl_ca_crl   = $::puppet::server::ssl_ca_crl
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

  file {'puppet_vhost':
    path    => "${apache::params::configdir}/puppet.conf",
    content => template('puppet/server/puppet-vhost.conf.erb'),
    mode    => '0644',
    notify  => Exec['reload-apache'],
    before  => Service[$::puppet::server_httpd_service],
    require => Class['::puppet::server::rack'],
  }

}
