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

  package { $server_package:
    ensure => $::puppet::version,
  }

  if $puppet::server_git_repo {
    file { $puppet::vardir:
      ensure => directory,
      owner  => $puppet::server_user,
    }

    user { $puppet::server_user:
      shell   => '/usr/bin/git-shell',
      require => Class['::git::install'],
    }
  }
}
