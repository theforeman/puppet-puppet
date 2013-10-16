# Set up the puppet server config
class puppet::server::config inherits puppet::config {
  if $puppet::server_passenger {
    # Anchor the passenger config inside this
    class { 'puppet::server::passenger': } -> Class['puppet::server::config']
  }

  # Mirror the relationship, as defined() is parse-order dependent
  # Ensures puppetmasters certs are generated before the proxy is needed
  if defined(Class['foreman_proxy::config']) and $foreman_proxy::ssl {
    Class['puppet::server::config'] -> Class['foreman_proxy::config']
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

  # Include foreman components for the puppetmaster
  # ENC script, reporting script etc.
  class {'foreman::puppetmaster':
    foreman_url    => $puppet::server_foreman_url,
    facts          => $puppet::server_facts,
    puppet_home    => $puppet::server_puppet_home,
    puppet_basedir => $puppet::server_puppet_basedir,
    enc_api        => $puppet::server_enc_api,
    report_api     => $puppet::server_report_api,
    ssl_ca         => $puppet::server_foreman_ssl_ca,
    ssl_cert       => $puppet::server_foreman_ssl_cert,
    ssl_key        => $puppet::server_foreman_ssl_key,
  }

  $ca_server                   = $::puppet::ca_server
  $server_storeconfigs_backend = $::puppet::server_storeconfigs_backend
  $server_external_nodes       = $::puppet::server_external_nodes

  if $server_external_nodes {
    $server_node_terminus = 'exec'
  } else {
    $server_node_terminus = 'plain'
  }

  # appends our server configuration to puppet.conf
  File ["${puppet::server_dir}/puppet.conf"] {
    content => template($puppet::agent_template, $puppet::server_template),
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
    notify  => Service[$puppet::server_httpd_service],
  }

  file { "${puppet::server_vardir}/reports":
    ensure => directory,
    owner  => $puppet::server_user,
  }

  # location where our puppet environments are located
  file { $puppet::server_envs_dir:
    ensure => directory,
    owner  => $puppet::server_environments_owner,
  }

  if $puppet::server_git_repo {

    # need to chown the $vardir before puppet does it, or else
    # we can't write puppet.git/ on the first run

    file { $puppet::server_vardir:
      ensure => directory,
      owner  => $puppet::server_user,
    }

    include git

    git::repo { 'puppet_repo':
      bare    => true,
      target  => $puppet::server_git_repo_path,
      user    => $puppet::server_user,
      require => File[$puppet::server_envs_dir],
    }

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
      ensure  => present,
      replace => false,
      content => "# Empty site.pp required (puppet #15106, foreman #1708)\n",
    }

    # setup empty directories for our environments
    puppet::server::env {$puppet::server_environments: }
  }
}
