# Set up the puppet server config
class puppet::server::config inherits puppet::config {
  if $puppet::server_passenger and $::puppet::server_implementation == 'master' {
    # Anchor the passenger config inside this
    class { '::puppet::server::passenger': } -> Class['puppet::server::config']
  }

  # Mirror the relationship, as defined() is parse-order dependent
  # Ensures puppetmasters certs are generated before the proxy is needed
  if defined(Class['foreman_proxy::config']) and $foreman_proxy::ssl {
    Class['puppet::server::config'] ~> Class['foreman_proxy::config']
    Class['puppet::server::config'] ~> Class['foreman_proxy::service']
  }

  # Open read permissions to private keys to puppet group for foreman, proxy etc.
  file { "${puppet::server_ssl_dir}/private_keys":
    group => $puppet::server_group,
    mode  => '0750',
  }

  file { "${puppet::server_ssl_dir}/private_keys/${::fqdn}.pem":
    group => $puppet::server_group,
    mode  => '0640',
  }

  if $::puppet::server_foreman {
    # Include foreman components for the puppetmaster
    # ENC script, reporting script etc.
    anchor { 'puppet::server::config_start': } ->
    class {'::foreman::puppetmaster':
      foreman_url    => $puppet::server_foreman_url,
      receive_facts  => $puppet::server_facts,
      puppet_home    => $puppet::vardir,
      puppet_basedir => $puppet::server_puppet_basedir,
      enc_api        => $puppet::server_enc_api,
      report_api     => $puppet::server_report_api,
      timeout        => $puppet::server_request_timeout,
      ssl_ca         => pick($puppet::server_foreman_ssl_ca, $puppet::server::ssl_ca_cert),
      ssl_cert       => pick($puppet::server_foreman_ssl_cert, $puppet::server::ssl_cert),
      ssl_key        => pick($puppet::server_foreman_ssl_key, $puppet::server::ssl_cert_key),
    } ~> anchor { 'puppet::server::config_end': }
  }

  $ca_server                   = $::puppet::ca_server
  $ca_port                     = $::puppet::ca_port
  $server_storeconfigs_backend = $::puppet::server_storeconfigs_backend
  $server_external_nodes       = $::puppet::server_external_nodes

  if $server_external_nodes {
    $server_node_terminus = 'exec'
  } else {
    $server_node_terminus = 'plain'
  }

  concat_fragment { 'puppet.conf+30-master':
    content => template($puppet::server_template),
  }

  ## If the ssl dir is not the default dir, it needs to be created before running
  # the generate ca cert or it will fail.
  exec {'puppet_server_config-create_ssl_dir':
    creates => $::puppet::server_ssl_dir,
    command => "/bin/mkdir -p ${::puppet::server_ssl_dir}",
    before  => Exec['puppet_server_config-generate_ca_cert'],
  }

  exec {'puppet_server_config-generate_ca_cert':
    creates => $::puppet::server::ssl_cert,
    command => "${puppet::params::puppetca_path}/${puppet::params::puppetca_bin} --generate ${::fqdn}",
    require => File["${puppet::server_dir}/puppet.conf"],
  }

  if $puppet::server_passenger and $::puppet::server_implementation == 'master' {
    Exec['puppet_server_config-generate_ca_cert'] ~> Service[$puppet::server_httpd_service]
  }

  file { "${puppet::vardir}/reports":
    ensure => directory,
    owner  => $puppet::server_user,
  }

  # location where our puppet environments are located
  file { $puppet::server_envs_dir:
    ensure => directory,
    owner  => $puppet::server_environments_owner,
    group  => $puppet::server_environments_group,
    mode   => $puppet::server_environments_mode,
  }

  if $puppet::server_git_repo {

    # need to chown the $vardir before puppet does it, or else
    # we can't write puppet.git/ on the first run

    include ::git

    git::repo { 'puppet_repo':
      bare    => true,
      target  => $puppet::server_git_repo_path,
      user    => $puppet::server_user,
      require => File[$puppet::server_envs_dir],
    }

    $git_branch_map = $puppet::server_git_branch_map
    # git post hook to auto generate an environment per branch
    file { "${puppet::server_git_repo_path}/hooks/${puppet::server_post_hook_name}":
      content => template($puppet::server_post_hook_content),
      owner   => $puppet::server_user,
      mode    => '0755',
      require => Git::Repo['puppet_repo'],
    }

  }
  elsif ! $puppet::server_dynamic_environments {
    file { ['/usr/share/puppet', $puppet::server_common_modules_path]:
      ensure => directory,
    }

    # make sure your site.pp exists (puppet #15106, foreman #1708)
    file { "${puppet::server_manifest_path}/site.pp":
      ensure  => file,
      replace => false,
      content => "# site.pp must exist (puppet #15106, foreman #1708)\n",
      mode    => '0644',
    }

    # setup empty directories for our environments
    puppet::server::env {$puppet::server_environments: }
  }

  # PuppetDB
  if $puppet::server_puppetdb_host {
    class { '::puppetdb::master::config':
      puppetdb_server             => $puppet::server_puppetdb_host,
      puppetdb_port               => $puppet::server_puppetdb_port,
      puppetdb_soft_write_failure => $puppet::server_puppetdb_swf,
      manage_storeconfigs         => false,
      restart_puppet              => false,
    }
  }
}
