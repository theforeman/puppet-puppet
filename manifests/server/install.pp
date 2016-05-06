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

  if $::puppet::manage_packages == true or $::puppet::manage_packages == 'server' {
    $server_package_default = $::puppet::server::implementation ? {
      'master'       => $::osfamily ? {
        'Debian'                => ['puppetmaster-common','puppetmaster'],
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
  }

  if $::puppet::server::git_repo {
    file { $puppet::vardir:
      ensure => directory,
      owner  => $::puppet::server::user,
      group  => $::puppet::server::group,
    }

    $git_shell = $::osfamily ? {
      /^(FreeBSD|DragonFly)$/ => '/usr/local/bin/git-shell',
      default                 => '/usr/bin/git-shell'
    }

    user { $::puppet::server::user:
      shell   => $git_shell,
      require => Class['::git::install'],
    }
  }
}
