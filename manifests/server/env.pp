# Set up a puppet environment
define puppet::server::env (
  $basedir        = $::puppet::server_envs_dir,
  $config_version = $::puppet::server::config::config_version,
  $manifest       = undef,
  $manifestdir    = undef,
  $modulepath     = flatten([
    "${::puppet::server_envs_dir}/${name}/modules",
    $::puppet::server_common_modules_path,
  ]),
  $templatedir    = undef
) {
  file { "${basedir}/${name}":
    ensure => directory,
  }

  file { "${basedir}/${name}/modules":
    ensure => directory,
  }

  concat_fragment { "puppet.conf+40-${name}":
    content => template('puppet/server/puppet.conf.env.erb')
  }
}
