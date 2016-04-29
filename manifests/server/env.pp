# Set up a puppet environment
define puppet::server::env (
  $basedir                = $::puppet::server::envs_dir,
  $config_version         = $::puppet::server::config_version_cmd,
  $manifest               = undef,
  $manifestdir            = undef,
  $modulepath             = undef,
  $templatedir            = undef,
  $environment_timeout    = $::puppet::server::environment_timeout,
  $directory_environments = $::puppet::server::directory_environments,
  $owner                  = $::puppet::server::environments_owner,
  $group                  = $::puppet::server::environments_group,
  $mode                   = $::puppet::server::environments_mode,
) {

  $default_modulepath = ["${basedir}/${name}/modules", $::puppet::server::common_modules_path]
  if $modulepath == undef {
    $custom_modulepath = false
    $real_modulepath   = $default_modulepath
  } else {
    $custom_modulepath = ($modulepath != $default_modulepath)
    $real_modulepath   = $modulepath
  }

  file { "${basedir}/${name}":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }

  file { "${basedir}/${name}/modules":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }

  if $directory_environments {
    file { "${basedir}/${name}/manifests":
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }

    if $manifest or $config_version or $custom_modulepath or $environment_timeout {
      file { "${basedir}/${name}/environment.conf":
        ensure  => file,
        owner   => $owner,
        group   => $group,
        mode    => '0644',
        content => template('puppet/server/environment.conf.erb'),
      }
    }
  } else {
    concat::fragment { "puppet.conf+40-${name}":
      target  => "${::puppet::dir}/puppet.conf",
      content => template('puppet/server/puppet.conf.env.erb'),
      order   => '40',
    }
  }
}
