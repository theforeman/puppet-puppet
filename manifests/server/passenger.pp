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
  include ::apache::ssl
  include ::apache::params
  include ::passenger

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
