# Set up a puppet environment
define puppet::server::env ($basedir = $puppet::server::envs_dir) {
  file { "${basedir}/${name}":
    ensure => directory,
  }
}
