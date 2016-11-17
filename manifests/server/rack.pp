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
  $app_root       = $::puppet::server::passenger::app_root,
  $confdir        = $::puppet::server::passenger::confdir,
  $rack_arguments = $::puppet::server::passenger::rack_arguments,
  $user           = $::puppet::server::passenger::user,
  $vardir         = $::puppet::server::passenger::vardir,
) {
  file {
    [$app_root, "${app_root}/public", "${app_root}/tmp"]:
      ensure => directory,
      owner  => $user,
      mode   => '0755',
  }

  file { "${app_root}/config.ru":
    owner   => $user,
    content => template('puppet/server/config.ru.erb'),
  }

}
