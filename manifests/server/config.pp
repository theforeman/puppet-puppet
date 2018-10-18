# Set up the puppet server config
class puppet::server::config inherits puppet::config {
  if $::puppet::server::passenger and $::puppet::server::implementation == 'master' {
    contain 'puppet::server::passenger'
  }

  if $::puppet::server::implementation == 'puppetserver' {
    contain 'puppet::server::puppetserver'
    unless empty($::puppet::server::puppetserver_vardir) {
      puppet::config::master {
        'vardir': value => $::puppet::server::puppetserver_vardir;
      }
    }
    unless empty($::puppet::server::puppetserver_rundir) {
      puppet::config::master {
        'rundir': value => $::puppet::server::puppetserver_rundir;
      }
    }
    unless empty($::puppet::server::puppetserver_logdir) {
      puppet::config::master {
        'logdir': value => $::puppet::server::puppetserver_logdir;
      }
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
  $ca_server                   = $::puppet::ca_server
  $ca_port                     = $::puppet::ca_port
  $server_storeconfigs_backend = $::puppet::server::storeconfigs_backend
  $server_external_nodes       = $::puppet::server::external_nodes
  $server_environment_timeout  = $::puppet::server::environment_timeout

  if $server_external_nodes and $server_external_nodes != '' {
    class{ '::puppet::server::enc':
      enc_path => $server_external_nodes,
    }
  }

  $autosign = ($::puppet::server::autosign =~ Boolean)? {
    true  => $::puppet::server::autosign,
    false => "${::puppet::server::autosign} { mode = ${::puppet::server::autosign_mode} }"
  }

  puppet::config::main {
    'reports':            value => $::puppet::server::reports;
  }
  if $::puppet::server::hiera_config and !empty($::puppet::server::hiera_config){
    puppet::config::main {
      'hiera_config':       value => $::puppet::server::hiera_config;
    }
  }
  if $puppet::server::directory_environments {
    puppet::config::main {
      'environmentpath':  value => $puppet::server::envs_dir;
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
    'ca':                 value => $::puppet::server::ca;
    'certname':           value => $::puppet::server::certname;
    'parser':             value => $::puppet::server::parser;
    'strict_variables':   value => $::puppet::server::strict_variables;
  }

  if $::puppet::server::ssl_dir_manage {
    puppet::config::master {
      'ssldir':           value => $::puppet::server::ssl_dir;
    }
  }
  if $server_environment_timeout {
    puppet::config::master {
      'environment_timeout':  value => $server_environment_timeout;
    }
  }
  if $server_storeconfigs_backend {
    puppet::config::master {
      'storeconfigs':         value => true;
      'storeconfigs_backend': value => $server_storeconfigs_backend;
    }
  }
  if !$::puppet::server::directory_environments and ($::puppet::server::git_repo or $::puppet::server::dynamic_environments) {
    puppet::config::master {
      'manifest':   value => "${::puppet::server::envs_dir}/\$environment/manifests/site.pp";
      'modulepath': value => "${::puppet::server::envs_dir}/\$environment/modules";
    }
    if $::puppet::server::config_version_cmd {
      puppet::config::master {
        'config_version': value => $::puppet::server::config_version_cmd;
      }
    }
  }

  $::puppet::server_additional_settings.each |$key,$value| {
    puppet::config::master { $key: value => $value }
  }

  file { "${puppet::vardir}/reports":
    ensure => directory,
    owner  => $::puppet::server::user,
    group  => $::puppet::server::group,
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
  file { "${::puppet::server::ssl_dir}/private_keys":
    ensure  => directory,
    owner   => $::puppet::server::user,
    group   => $::puppet::server::group,
    mode    => '0750',
    require => Exec['puppet_server_config-create_ssl_dir'],
  }

  if $puppet::server::ssl_key_manage {
    file { "${::puppet::server::ssl_dir}/private_keys/${::puppet::server::certname}.pem":
      owner => $::puppet::server::user,
      group => $::puppet::server::group,
      mode  => '0640',
    }
  }

  if $puppet::server::custom_trusted_oid_mapping {
    $_custom_trusted_oid_mapping = {
      oid_mapping => $puppet::server::custom_trusted_oid_mapping,
    }
    file { "${::puppet::dir}/custom_trusted_oid_mapping.yaml":
      ensure  => file,
      owner   => 'root',
      group   => $::puppet::params::root_group,
      mode    => '0644',
      content => to_yaml($_custom_trusted_oid_mapping),
    }
  }

  # If the ssl dir is not the default dir, it needs to be created before running
  # the generate ca cert or it will fail.
  exec {'puppet_server_config-create_ssl_dir':
    creates => $::puppet::server::ssl_dir,
    command => "/bin/mkdir -p ${::puppet::server::ssl_dir}",
    umask   => '0022',
  }

  # Generate a new CA and host cert if our host cert doesn't exist
  if $::puppet::server::ca {
    if versioncmp($::puppetversion, '6.0') > 0 {
      $command = "${::puppet::puppetserver_cmd} ca setup"
    } else {
      $command = "${::puppet::puppet_cmd} cert --generate ${::puppet::server::certname} --allow-dns-alt-names"
    }

    exec {'puppet_server_config-generate_ca_cert':
      creates => $::puppet::server::ssl_cert,
      command => $command,
      umask   => '0022',
      require => [
        Concat["${::puppet::server::dir}/puppet.conf"],
        Exec['puppet_server_config-create_ssl_dir'],
      ],
    }
  } elsif $::puppet::server::ca_crl_sync {
    # If not a ca AND sync the crl from the ca master
    if defined('$::servername') {
      file { $::puppet::server::ssl_ca_crl:
        ensure  => file,
        owner   => $::puppet::server::user,
        group   => $::puppet::server::group,
        mode    => '0644',
        content => file($::settings::cacrl, $::settings::hostcrl, '/dev/null'),
      }
    }
  }

  if $::puppet::server::passenger and $::puppet::server::implementation == 'master' and $::puppet::server::ca {
    Exec['puppet_server_config-generate_ca_cert'] ~> Service[$::puppet::server::httpd_service]
  }

  # autosign file
  if $::puppet::server_ca and !($puppet::server::autosign =~ Boolean) {
    if $::puppet::server::autosign_content or $::puppet::server::autosign_source {
      if !empty($::puppet::server::autosign_entries) {
        fail('Cannot set both autosign_content/autosign_source and autosign_entries')
      }
      $autosign_content = $::puppet::server::autosign_content
    } elsif !empty($::puppet::server::autosign_entries) {
      $autosign_content = template('puppet/server/autosign.conf.erb')
    } else {
      $autosign_content = undef
    }
    file { $::puppet::server::autosign:
      ensure  => file,
      owner   => $::puppet::server::user,
      group   => $::puppet::server::group,
      mode    => $::puppet::server::autosign_mode,
      content => $autosign_content,
      source  => $::puppet::server::autosign_source,
    }
  }

  # only manage this file if we provide content
  if $::puppet::server::default_manifest and $::puppet::server::default_manifest_content != '' {
    file { $::puppet::server::default_manifest_path:
      ensure  => file,
      owner   => $puppet::user,
      group   => $puppet::group,
      mode    => '0644',
      content => $::puppet::server::default_manifest_content,
    }
  }

  ## Environments
  # location where our puppet environments are located
  if $::puppet::server::envs_target and $::puppet::server::envs_target != '' {
    $ensure = 'link'
  } else {
    $ensure = 'directory'
  }

  file { $::puppet::server::envs_dir:
    ensure => $ensure,
    owner  => $::puppet::server::environments_owner,
    group  => $::puppet::server::environments_group,
    mode   => $::puppet::server::environments_mode,
    target => $::puppet::server::envs_target,
    force  => true,
  }

  if $::puppet::server::git_repo {
    # need to chown the $vardir before puppet does it, or else
    # we can't write puppet.git/ on the first run

    include ::git

    git::repo { 'puppet_repo':
      bare    => true,
      target  => $::puppet::server::git_repo_path,
      mode    => $::puppet::server::git_repo_mode,
      user    => $::puppet::server::git_repo_user,
      group   => $::puppet::server::git_repo_group,
      require => File[$::puppet::server::envs_dir],
    }

    $git_branch_map = $::puppet::server::git_branch_map
    # git post hook to auto generate an environment per branch
    file { "${::puppet::server::git_repo_path}/hooks/${::puppet::server::post_hook_name}":
      content => template($::puppet::server::post_hook_content),
      owner   => $::puppet::server::git_repo_user,
      group   => $::puppet::server::git_repo_group,
      mode    => $::puppet::server::git_repo_mode,
      require => Git::Repo['puppet_repo'],
    }

  }
  elsif ! $::puppet::server::dynamic_environments {
    file { $puppet::sharedir:
      ensure => directory,
    }

    if $::puppet::server::common_modules_path and $::puppet::server::common_modules_path != '' {
      file { $::puppet::server::common_modules_path:
        ensure => directory,
        owner  => $::puppet::server_environments_owner,
        group  => $::puppet::server_environments_group,
        mode   => $::puppet::server_environments_mode,
      }
    }

    # setup empty directories for our environments
    puppet::server::env {$::puppet::server::environments: }
  }

  ## Foreman
  if $::puppet::server::foreman {
    # Include foreman components for the puppetmaster
    # ENC script, reporting script etc.
    class { 'foreman::puppetmaster':
      foreman_url    => $::puppet::server::foreman_url,
      receive_facts  => $::puppet::server::server_foreman_facts,
      puppet_home    => $::puppet::server::puppetserver_vardir,
      puppet_basedir => $::puppet::server::puppet_basedir,
      puppet_etcdir  => $puppet::dir,
      enc_api        => $::puppet::server::enc_api,
      report_api     => $::puppet::server::report_api,
      timeout        => $::puppet::server::request_timeout,
      ssl_ca         => pick($::puppet::server::foreman_ssl_ca, $::puppet::server::ssl_ca_cert),
      ssl_cert       => pick($::puppet::server::foreman_ssl_cert, $::puppet::server::ssl_cert),
      ssl_key        => pick($::puppet::server::foreman_ssl_key, $::puppet::server::ssl_cert_key),
    }
    contain foreman::puppetmaster
  }

  ## PuppetDB
  if $::puppet::server::puppetdb_host {
    class { '::puppetdb::master::config':
      puppetdb_server             => $::puppet::server::puppetdb_host,
      puppetdb_port               => $::puppet::server::puppetdb_port,
      puppetdb_soft_write_failure => $::puppet::server::puppetdb_swf,
      manage_storeconfigs         => false,
      restart_puppet              => false,
    }
    Class['puppetdb::master::puppetdb_conf'] ~> Class['puppet::server::service']
  }
}
