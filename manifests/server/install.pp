# Install the puppet server
class puppet::server::install {

  package { $puppet::server_package:
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
