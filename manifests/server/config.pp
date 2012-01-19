class puppet::server::config inherits puppet::config {
  if $puppet::params::passenger  { include puppet::server::passenger }

  File ["${puppet::params::dir}/puppet.conf"] {
    content => template('puppet/puppet.conf.erb', 'puppet/server/puppet.conf.erb'),
  }

  file { [$puppet::params::modules_path, $puppet::params::common_modules_path]:
    ensure => directory,
  }

  exec {'generate_ca_cert':
    creates => "${puppet::params::ssl_dir}/certs/${::fqdn}.pem",
    command => "puppetca --generate ${::fqdn}",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  # setup empty directories for our environments
  puppet::server::env {$puppet::params::environments: }

}
