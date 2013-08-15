# Set up a puppet environment
define puppet::server::env ($basedir = $puppet::server_envs_dir) {
  file { "${basedir}/${name}":
    ensure => directory,
  }

  file { "${basedir}/${name}/modules":
    ensure => directory,
  }
}
