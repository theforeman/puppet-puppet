class puppet::server::passenger {
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

  exec {'generate_ca_cert':
    creates => "${puppet::server::ssl_dir}/certs/${::fqdn}.pem",
    command => "${puppet::params::puppetca_path}/${puppet::params::puppetca_bin} --generate ${::fqdn}",
    require => File["${puppet::dir}/puppet.conf"],
    notify  => Service['httpd'],
  }

  file {'puppet_vhost':
    path    => "${apache::params::configdir}/puppet.conf",
    content => template('puppet/server/puppet-vhost.conf.erb'),
    mode    => '0644',
    notify  => Exec['reload-apache'],
  }

  exec {'restart_puppet':
    command     => "/bin/touch ${puppet::server::app_root}/tmp/restart.txt",
    refreshonly => true,
    cwd         => $puppet::server::app_root,
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    require     => [Class['puppet::server::install'],File["${puppet::server::app_root}/tmp"]],
  }

  file {
    [$puppet::server::app_root, "${puppet::server::app_root}/public", "${puppet::server::app_root}/tmp"]:
      ensure => directory,
      owner  => $puppet::server::user,
      before => Class['apache::install'],
  }

  $configru_version = $::puppetversion ? {
    /^2.*/  => 'config.ru.2',
    default => 'config.ru'
  }
  file {
    "${puppet::server::app_root}/config.ru":
      owner  => $puppet::server::user,
      source => "puppet:///modules/puppet/${configru_version}",
      notify => Exec['restart_puppet'],
  }

}
