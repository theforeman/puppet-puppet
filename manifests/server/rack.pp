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
class puppet::server::rack(
  $app_root       = $::puppet::server::app_root,
  $confdir        = $::puppet::server::dir,
  $rack_arguments = $::puppet::server::rack_arguments,
  $user           = $::puppet::server::user,
  $vardir         = $::puppet::vardir,
) {
  exec {'puppet_server_rack-restart':
    command     => "touch ${app_root}/tmp/restart.txt",
    cwd         => $app_root,
    path        => '/bin:/usr/bin',
    refreshonly => true,
    require     => [
      Class['puppet::server::install'],
      File["${app_root}/tmp"]
    ],
  }

  file {
    [$app_root, "${app_root}/public", "${app_root}/tmp"]:
      ensure => directory,
      owner  => $user,
      mode   => '0755',
  }

  file {
    "${app_root}/config.ru":
      owner   => $user,
      content => template('puppet/server/config.ru.erb'),
      notify  => Exec['puppet_server_rack-restart'],
  }

}
