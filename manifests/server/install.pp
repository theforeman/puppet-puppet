# Install the puppet server
class puppet::server::install {

  $server_package_default = $::puppet::server_implementation ? {
    'master'       => $::operatingsystem ? {
      /(Debian|Ubuntu)/ => ['puppetmaster-common','puppetmaster'],
      default           => ['puppet-server'],
    },
    'puppetserver' => 'puppetserver',
  }
  $server_package = pick($::puppet::server_package, $server_package_default)

  if $::operatingsystem == 'CentOs' {
    package {"puppet_yum_repo":
      name => "puppetlabs-release",
      source => "http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm",
      ensure => present,
      provider => rpm,
      before => Package["puppet-server"],
    }
  }

  package { $server_package:
    ensure => $::puppet::version,
  }

  if $puppet::server_git_repo {
    file { $puppet::server_vardir:
      ensure => directory,
      owner  => $puppet::server_user,
    }

    user { $puppet::server_user:
      shell => '/usr/bin/git-shell',
    }
  }
}
