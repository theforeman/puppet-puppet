define puppet::server::env () {
  require puppet::params
  file { "${puppet::params::modules_path}/${name}":
    ensure => directory,
  }
}
