define puppet::server::env ($basedir = $puppet::server::modules_path) {
  file { "${basedir}/${name}":
    ensure => directory,
  }
}
