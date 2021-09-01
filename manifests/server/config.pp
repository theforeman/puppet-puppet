# Set up the puppet server config
# @api private
class puppet::server::config inherits puppet::config {
  contain 'puppet::server::puppetserver'
  unless empty($puppet::server::puppetserver_vardir) {
    puppet::config::master {
      'vardir': value => $puppet::server::puppetserver_vardir;
    }
  }
  unless empty($puppet::server::puppetserver_rundir) {
    puppet::config::master {
      'rundir': value => $puppet::server::puppetserver_rundir;
    }
  }
  unless empty($puppet::server::puppetserver_logdir) {
    puppet::config::master {
      'logdir': value => $puppet::server::puppetserver_logdir;
    }
  }

  # Mirror the relationship, as defined() is parse-order dependent
  # Ensures puppetmasters certs are generated before the proxy is needed
  if defined(Class['foreman_proxy::config']) and $foreman_proxy::ssl {
    Class['puppet::server::config'] ~> Class['foreman_proxy::config']
    Class['puppet::server::config'] ~> Class['foreman_proxy::service']
  }

  # And before Foreman's cert-using service needs it
  if defined(Class['foreman::service']) and $foreman::ssl {
    Class['puppet::server::config'] -> Class['foreman::service']
  }

  ## General configuration
  $ca_server                   = $puppet::ca_server
  $ca_port                     = $puppet::ca_port
  $server_external_nodes       = $puppet::server::external_nodes
  $server_environment_timeout  = $puppet::server::environment_timeout
  $trusted_external_command    = $puppet::server::trusted_external_command
  $primary_envs_dir            = $puppet::server::envs_dir[0]

  if $server_external_nodes and $server_external_nodes != '' {
    class { 'puppet::server::enc':
      enc_path => $server_external_nodes,
    }
  }

  if $trusted_external_command {
    puppet::config::master {
      'trusted_external_command': value => $trusted_external_command,
    }
  }

  $autosign = ($puppet::server::autosign =~ Boolean)? {
    true  => $puppet::server::autosign,
    false => "${puppet::server::autosign} { mode = ${puppet::server::autosign_mode} }"
  }

  puppet::config::main {
    'reports':            value => $puppet::server::reports;
    'environmentpath':    value => $puppet::server::envs_dir.join(':');
  }
  if $puppet::server::hiera_config and !empty($puppet::server::hiera_config) {
    puppet::config::main {
      'hiera_config':       value => $puppet::server::hiera_config;
    }
  }
  if $puppet::server::common_modules_path and !empty($puppet::server::common_modules_path) {
    puppet::config::main {
      'basemodulepath':   value => $puppet::server::common_modules_path, joiner => ':';
    }
  }
  if $puppet::server::default_manifest {
    puppet::config::main {
      'default_manifest': value => $puppet::server::default_manifest_path;
    }
  }

  puppet::config::master {
    'autosign':           value => $autosign;
    'ca':                 value => $puppet::server::ca;
    'certname':           value => $puppet::server::certname;
    'parser':             value => $puppet::server::parser;
    'strict_variables':   value => $puppet::server::strict_variables;
    'storeconfigs':       value => $puppet::server::storeconfigs;
  }

  if $puppet::server::ssl_dir_manage {
    puppet::config::master {
      'ssldir':           value => $puppet::server::ssl_dir;
    }
  }
  if $server_environment_timeout {
    puppet::config::master {
      'environment_timeout':  value => $server_environment_timeout;
    }
  }

  $puppet::server_additional_settings.each |$key,$value| {
    puppet::config::master { $key: value => $value }
  }

  file { "${puppet::vardir}/reports":
    ensure => directory,
    owner  => $puppet::server::user,
    group  => $puppet::server::group,
    mode   => '0750',
  }

  if '/usr/share/puppet/modules' in $puppet::server::common_modules_path {
    # Create Foreman share dir which does not depend on Puppet version
    exec { 'mkdir -p /usr/share/puppet/modules':
      creates => '/usr/share/puppet/modules',
      path    => ['/usr/bin', '/bin'],
    }
  }

  ## SSL and CA configuration
  # Open read permissions to private keys to puppet group for foreman, proxy etc.
  file { "${puppet::server::ssl_dir}/private_keys":
    ensure  => directory,
    owner   => $puppet::server::user,
    group   => $puppet::server::group,
    mode    => '0750',
    require => Exec['puppet_server_config-create_ssl_dir'],
  }

  if $puppet::server::ssl_key_manage {
    file { "${puppet::server::ssl_dir}/private_keys/${puppet::server::certname}.pem":
      owner => $puppet::server::user,
      group => $puppet::server::group,
      mode  => '0640',
    }
  }

  if $puppet::server::custom_trusted_oid_mapping {
    $_custom_trusted_oid_mapping = {
      oid_mapping => $puppet::server::custom_trusted_oid_mapping,
    }
    file { "${puppet::dir}/custom_trusted_oid_mapping.yaml":
      ensure  => file,
      owner   => 'root',
      group   => $puppet::params::root_group,
      mode    => '0644',
      content => to_yaml($_custom_trusted_oid_mapping),
    }
  }

  # If the ssl dir is not the default dir, it needs to be created before running
  # the generate ca cert or it will fail.
  exec { 'puppet_server_config-create_ssl_dir':
    creates => $puppet::server::ssl_dir,
    command => "/bin/mkdir -p ${puppet::server::ssl_dir}",
    umask   => '0022',
  }

  # Generate a new CA and host cert if our host cert doesn't exist
  if $puppet::server::ca {
    exec { 'puppet_server_config-generate_ca_cert':
      creates => $puppet::server::ssl_ca_cert,
      command => "${puppet::puppetserver_cmd} ca setup",
      umask   => '0022',
      require => [
        Concat["${puppet::server::dir}/puppet.conf"],
        Exec['puppet_server_config-create_ssl_dir'],
      ],
    }

    # In Puppet 7 the cadir was changed from $ssldir/ca to $puppetserver_dir/ca
    # This migrates the directory if it was in the old location
    # The migration command leaves a symlink in place
    if versioncmp($puppet::server::real_puppetserver_version, '7.0') > 0 {
      exec { 'migrate Puppetserver cadir':
        command => "${puppet::puppetserver_cmd} ca migrate",
        creates => $puppet::server::cadir,
        onlyif  => "test -d '${puppet::server::ssl_dir}/ca' && ! test -L '${puppet::server::ssl_dir}'",
        path    => $facts['path'],
        before  => Exec['puppet_server_config-generate_ca_cert'],
      }
    }
  } elsif $puppet::server::ca_crl_sync {
    # If not a ca AND sync the crl from the ca master
    if $server_facts['servername'] {
      file { $puppet::server::ssl_ca_crl:
        ensure  => file,
        owner   => $puppet::server::user,
        group   => $puppet::server::group,
        mode    => '0644',
        content => file($settings::cacrl, $settings::hostcrl, '/dev/null'),
      }
    }
  }

  # autosign file
  if $puppet::server_ca and !($puppet::server::autosign =~ Boolean) {
    if $puppet::server::autosign_content or $puppet::server::autosign_source {
      if !empty($puppet::server::autosign_entries) {
        fail('Cannot set both autosign_content/autosign_source and autosign_entries')
      }
      $autosign_content = $puppet::server::autosign_content
    } elsif !empty($puppet::server::autosign_entries) {
      $autosign_content = template('puppet/server/autosign.conf.erb')
    } else {
      $autosign_content = undef
    }
    file { $puppet::server::autosign:
      ensure  => file,
      owner   => $puppet::server::user,
      group   => $puppet::server::group,
      mode    => $puppet::server::autosign_mode,
      content => $autosign_content,
      source  => $puppet::server::autosign_source,
    }
  }

  # only manage this file if we provide content
  if $puppet::server::default_manifest and $puppet::server::default_manifest_content != '' {
    file { $puppet::server::default_manifest_path:
      ensure  => file,
      owner   => $puppet::user,
      group   => $puppet::group,
      mode    => '0644',
      content => $puppet::server::default_manifest_content,
    }
  }

  ## Environments
  # location where our puppet environments are located
  if $puppet::server::envs_target and $puppet::server::envs_target != '' {
    $ensure = 'link'
  } else {
    $ensure = 'directory'
  }

  file { $puppet::server::envs_dir:
    ensure => $ensure,
    owner  => $puppet::server::environments_owner,
    group  => $puppet::server::environments_group,
    mode   => $puppet::server::environments_mode,
    target => $puppet::server::envs_target,
    force  => true,
  }

  if $puppet::server::git_repo {
    include git

    if $puppet::server::manage_user {
      Class['git'] -> User[$puppet::server::user]
    }

    file { $puppet::vardir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
    }

    git::repo { 'puppet_repo':
      bare    => true,
      target  => $puppet::server::git_repo_path,
      mode    => $puppet::server::git_repo_mode,
      user    => $puppet::server::git_repo_user,
      group   => $puppet::server::git_repo_group,
      require => File[$puppet::vardir, $primary_envs_dir],
    }

    $git_branch_map = $puppet::server::git_branch_map
    # git post hook to auto generate an environment per branch
    file { "${puppet::server::git_repo_path}/hooks/${puppet::server::post_hook_name}":
      content => template($puppet::server::post_hook_content),
      owner   => $puppet::server::git_repo_user,
      group   => $puppet::server::git_repo_group,
      mode    => $puppet::server::git_repo_mode,
      require => Git::Repo['puppet_repo'],
    }
  }

  file { $puppet::sharedir:
    ensure => directory,
  }

  if $puppet::server::common_modules_path and !empty($puppet::server::common_modules_path) {
    file { $puppet::server::common_modules_path:
      ensure => directory,
      owner  => $puppet::server_environments_owner,
      group  => $puppet::server_environments_group,
      mode   => $puppet::server_environments_mode,
    }
  }

  if $puppet::server::foreman {
    contain puppet::server::foreman
  }
}
