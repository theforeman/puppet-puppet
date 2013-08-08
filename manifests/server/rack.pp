# = Class: puppet::server::rack
#
# Description of puppet::server::rack
#
# == Actions:
#
# Create a directory structure to use with passenger
#
# == Sample Usage:
#
# include puppet::server::rack
#
class puppet::server::rack {


  exec {'puppet_server_rack-restart':
    command     => "/bin/touch ${puppet::server_app_root}/tmp/restart.txt",
    refreshonly => true,
    cwd         => $puppet::server_app_root,
    require     => [
      Class['puppet::server::install'],
      File["${puppet::server_app_root}/tmp"]
    ],
  }

  file {
    [$puppet::server_app_root, "${puppet::server_app_root}/public", "${puppet::server_app_root}/tmp"]:
      ensure => directory,
      owner  => $puppet::server_user,
  }

  $configru_version = $::puppetversion ? {
    /^2.*/  => 'config.ru.2.erb',
    default => 'config.ru.erb'
  }
  file {
    "${puppet::server_app_root}/config.ru":
      owner   => $puppet::server_user,
      content => template("puppet/server/${configru_version}"),
      notify  => Exec['puppet_server_rack-restart'],
  }

}
