# Set up the puppet server config
class puppet::server::config inherits puppet::config {
  if $puppet::server::passenger {
    # Anchor the passenger config inside this
    class { 'puppet::server::passenger': } -> Class['puppet::server::config']
  }

  # Mirror the relationship, as defined() is parse-order dependent
  # Ensures puppetmasters certs are generated before the proxy is needed
  if defined(Class['foreman_proxy::config']) and $foreman_proxy::ssl {
    Class['puppet::server::config'] -> Class['foreman_proxy::config']
  }

  # Open read permissions to private keys to puppet group for foreman, proxy etc.
  file { "${puppet::server::ssl_dir}/private_keys":
    group => $puppet::server::group,
    mode  => '0750',
  }

  file { "${puppet::server::ssl_dir}/private_keys/${::fqdn}.pem":
    group => $puppet::server::group,
    mode  => '0640',
  }

  # Include foreman components for the puppetmaster
  # ENC script, reporting script etc.
  class {'foreman::puppetmaster':
    foreman_url    => $puppet::server::foreman_url,
    facts          => $puppet::server::facts,
    storeconfigs   => $puppet::server::storeconfigs,
    puppet_home    => $puppet::server::puppet_home,
    puppet_basedir => $puppet::server::puppet_basedir
  }

  # appends our server configuration to puppet.conf
  File ["${puppet::server::dir}/puppet.conf"] {
    content => template($puppet::server::agent_template, $puppet::server::master_template),
  }

  file { "${puppet::server::vardir}/reports":
    ensure => directory,
    owner  => $puppet::server::user,
  }

  if $puppet::server::git_repo {

    # location where our puppet environments are located
    file { $puppet::server::envs_dir:
      ensure => directory,
      owner  => $puppet::server::user,
    }

    # need to chown the $vardir before puppet does it, or else
    # we can't write puppet.git/ on the first run

    file { $puppet::server::vardir:
      ensure => directory,
      owner  => $puppet::server::user,
    }

    include git

    git::repo { 'puppet_repo':
      bare    => true,
      target  => $puppet::server::git_repo_path,
      user    => $puppet::server::user,
      require => File[$puppet::server::envs_dir],
    }

    # git post hook to auto generate an environment per branch
    file { "${puppet::server::git_repo_path}/hooks/${puppet::server::post_hook_name}":
      content => template($puppet::server::post_hook_content),
      owner   => $puppet::server::user,
      mode    => '0755',
      require => Git::Repo['puppet_repo'],
    }

  }
  else
  {
    file { [$puppet::server::modules_path, $puppet::server::common_modules_path]:
      ensure => directory,
    }

    # make sure your site.pp exists (puppet #15106, foreman #1708)
    file { "${puppet::server::manifest_path}/site.pp":
      ensure  => present,
      replace => false,
      content => "# Empty site.pp required (puppet #15106, foreman #1708)\n",
    }

    # setup empty directories for our environments
    puppet::server::env {$puppet::server::environments: }
  }

}
