# Install the puppet server
class puppet::server::install {

  if $::puppet::manage_packages == true or $::puppet::manage_packages == 'server' {
    $server_package_default = $::puppet::server_implementation ? {
      'master'       => $::osfamily ? {
        'Debian'                => ['puppetmaster-common','puppetmaster'],
        /^(FreeBSD|DragonFly)$/ => [],
        default                 => ['puppet-server'],
      },
      'puppetserver' => 'puppetserver',
    }
    $server_package = pick($::puppet::server_package, $server_package_default)
    $server_version = pick($::puppet::server_version, $::puppet::version)

    package { $server_package:
      ensure => $server_version,
    }
  }

  if $puppet::server_git_repo {
    file { $puppet::vardir:
      ensure => directory,
      owner  => $puppet::server_user,
      group  => $puppet::server_group,
    }

    $git_shell = $::osfamily ? {
      /^(FreeBSD|DragonFly)$/ => '/usr/local/bin/git-shell',
      default                 => '/usr/bin/git-shell'
    }

    user { $puppet::server_user:
      shell   => $git_shell,
      require => Class['::git::install'],
    }
  }
}
