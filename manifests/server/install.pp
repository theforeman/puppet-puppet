# Install the puppet server
# @api private
class puppet::server::install {

  # Mirror the relationship, as defined() is parse-order dependent
  # Ensures 'puppet' user group is present before managing users
  if defined(Class['foreman_proxy::config']) {
    Class['puppet::server::install'] -> Class['foreman_proxy::config']
  }
  if defined(Class['foreman::config']) {
    Class['puppet::server::install'] -> Class['foreman::config']
  }

  if $puppet::server::manage_user {
    $shell = $puppet::server::git_repo ? {
      true    => $facts['os']['family'] ? {
        /^(FreeBSD|DragonFly)$/ => '/usr/local/bin/git-shell',
        default                 => '/usr/bin/git-shell'
      },
      default => undef,
    }

    user { $puppet::server::user:
      shell => $shell,
    }
  }

  if $puppet::manage_packages == true or $puppet::manage_packages == 'server' {
    $server_package = pick($puppet::server::package, 'puppetserver')
    $server_version = pick($puppet::server::version, $puppet::version)

    package { $server_package:
      ensure          => $server_version,
      install_options => $puppet::package_install_options,
    }

    if $puppet::server::manage_user {
      Package[$server_package] -> User[$puppet::server::user]
    }
  }
}
