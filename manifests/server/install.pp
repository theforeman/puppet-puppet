# Install the puppet server
class puppet::server::install {

  # Mirror the relationship, as defined() is parse-order dependent
  # Ensures 'puppet' user group is present before managing users
  if defined(Class['foreman_proxy::config']) {
    Class['puppet::server::install'] -> Class['foreman_proxy::config']
  }
  if defined(Class['foreman::config']) {
    Class['puppet::server::install'] -> Class['foreman::config']
  }

  if $::puppet::server::manage_user {
    $shell = $::puppet::server::git_repo ? {
      true    => $::osfamily ? {
        /^(FreeBSD|DragonFly)$/ => '/usr/local/bin/git-shell',
        default                 => '/usr/bin/git-shell'
      },
      default => undef,
    }

    user { $::puppet::server::user:
      shell => $shell,
    }
  }

  if $::puppet::manage_packages == true or $::puppet::manage_packages == 'server' {
    $puppet4 = (versioncmp($::puppetversion, '4.0') > 0)
    $server_package_default = $::puppet::server::implementation ? {
      'master'       => $::osfamily ? {
        'Debian'                => $puppet4 ? {
                                      true    => ['puppet-master'],
                                      default => ['puppetmaster-common', 'puppetmaster'],
                                    },
        /^(FreeBSD|DragonFly)$/ => [],
        default                 => ['puppet-server'],
      },
      'puppetserver' => 'puppetserver',
    }
    $server_package = pick($::puppet::server::package, $server_package_default)
    $server_version = pick($::puppet::server::version, $::puppet::version)

    package { $server_package:
      ensure => $server_version,
    }

    if $::puppet::server::manage_user {
      Package[$server_package] -> User[$::puppet::server::user]
    }
  }

  # Prevent the master service running and preventing Apache from binding to the port
  if $::puppet::server::passenger and $::osfamily == 'Debian' {
    file { '/etc/default/puppetmaster':
      content => "START=no\n",
    }

    if $::puppet::manage_packages == true or $::puppet::manage_packages == 'server' {
      File['/etc/default/puppetmaster'] -> Package[$server_package]
    }
  }

  if $::puppet::server::git_repo {
    Class['git'] -> User[$::puppet::server::user]

    file { $puppet::vardir:
      ensure => directory,
      owner  => $::puppet::server::user,
      group  => $::puppet::server::group,
    }
  }
}
