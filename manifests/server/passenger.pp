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

  $ssl_dir      = $::puppet::server::ssl_dir
  $ssl_cert     = $::puppet::server::ssl_cert
  $ssl_cert_key = $::puppet::server::ssl_cert_key
  $ssl_ca_cert  = $::puppet::server::ssl_ca_cert
  # We check to surpress some warnings.
  if $::puppet::server::ca {
    $ssl_chain    = $::puppet::server::ssl_chain
    $ssl_ca_crl   = $::puppet::server::ssl_ca_crl
  }

  $port         = $::puppet::server::port
  $user         = $::puppet::server::user
  $app_root     = $::puppet::server::app_root

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
    before  => Service[$::puppet::server::httpd_service],
    require => Class['::puppet::server::rack'],
  }

}
