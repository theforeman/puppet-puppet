# == Class: puppet::server::passenger
#
# Set up the puppet server using passenger and apache.
#
class puppet::server::passenger {

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
    before  => Service[$::puppet::server::httpd_service],
    require => Class['::puppet::server::rack'],
  }

}
