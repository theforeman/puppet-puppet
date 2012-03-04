define puppet::server::env ($basedir = $puppet::params::modules_path) {
  file { "${basedir}/${name}":
    ensure => directory,
  }
}
