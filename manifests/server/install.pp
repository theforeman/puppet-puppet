# Install the puppet server
class puppet::server::install {

  package { $puppet::server_package:
    ensure => $::puppet::version,
  }

  if $puppet::server_git_repo {
    user { $puppet::server_user:
      shell => '/usr/bin/git-shell',
    }
  }
}
