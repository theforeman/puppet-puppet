class puppet::server::config inherits puppet::config {
  if $puppet::params::passenger { include puppet::server::passenger }

  # appends our server configuration to puppet.conf
  File ["${puppet::params::dir}/puppet.conf"] {
    content => template('puppet/puppet.conf.erb', 'puppet/server/puppet.conf.erb'),
  }

  exec {'generate_ca_cert':
    creates => "${puppet::params::ssl_dir}/certs/${::fqdn}.pem",
    command => "puppetca --generate ${::fqdn}",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  # location where our puppet environments are located
  file { $puppet::params::envs_dir:
    ensure => directory,
    owner  => $puppet::params::user,
  }

  if $puppet::params::git_repo {

    include git

    git::repo { 'puppet_repo':
      bare    => true,
      target  => "${puppet::params::envs_dir}/.git",
      user    => $puppet::params::user,
      require => File[$puppet::params::envs_dir],
    }

    # git post hook to auto generate an environment per branch
    file { "${puppet::params::envs_dir}/.git/hooks/post-receive":
      source  => 'puppet:///modules/puppet/post-receive',
      owner   => $puppet::params::user,
      mode    => '0555',
      require => Git::Repo['puppet_repo'],
    }

    user { $puppet::params::user:
      shell => '/usr/bin/git-shell',
    }

  }

}
