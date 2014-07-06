# Set up a puppet environment
define puppet::server::env (
  $basedir                = $::puppet::server_envs_dir,
  $config_version         = $::puppet::server::config_version_cmd,
  $manifest               = undef,
  $manifestdir            = undef,
  $modulepath             = ["${::puppet::server_envs_dir}/${name}/modules", $::puppet::server_common_modules_path],
  $templatedir            = undef,
  $environment_timeout    = undef,
  $directory_environments = $::puppet::server_directory_environments,
) {
  file { "${basedir}/${name}":
    ensure => directory,
  }

  file { "${basedir}/${name}/modules":
    ensure => directory,
  }

  if $directory_environments {
    file { "${basedir}/${name}/manifests":
      ensure => directory,
    }

    $custom_modulepath = $modulepath and ($modulepath != ["${basedir}/${name}/modules", $::puppet::server_common_modules_path])
    if $manifest or $config_version or $custom_modulepath or $environment_timeout {
      file { "${basedir}/${name}/environment.conf":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('puppet/server/environment.conf.erb'),
      }
    }
  } else {
    concat_fragment { "puppet.conf+40-${name}":
      content => template('puppet/server/puppet.conf.env.erb')
    }
  }
}
