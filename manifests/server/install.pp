# Install the puppet server
class puppet::server::install {

  package { $puppet::server::master_package:
    ensure => $::puppet::server::version,
  }

  if $puppet::server::git_repo {
    user { $puppet::server::user:
      shell => '/usr/bin/git-shell',
    }
  }
}
