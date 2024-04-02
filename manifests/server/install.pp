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

  if $puppet::server::git_repo {
    stdlib::ensure_packages(['git'])
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

    if $puppet::server::git_repo {
      Package['git'] -> User[$puppet::server::user]
    }
  }

  if $puppet::manage_packages == true or $puppet::manage_packages == 'server' {
    $server_package = pick($puppet::server::package, 'puppetserver')
    $server_version = pick($puppet::server::version, $puppet::version)

    package { $server_package:
      ensure          => $server_version,
      install_options => $puppet::package_install_options,
    }

    # Puppetserver 8 on EL 8 relies on JRE 11 or 17. This prefers JRE 17 by installing it first
    if (
      !$puppet::server::jvm_java_bin and
      $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '8' and
      # This doesn't use server_version because we have 2 mechanisms to set the version
      versioncmp(pick($puppet::server::puppetserver_version, $facts['puppetversion']), '8.0.0') >= 0
    ) {
      # EL 8 packaging can install either Java 17 or Java 11, but we prefer Java 17
      stdlib::ensure_packages(['jre-17-headless'])

      Package['jre-17-headless'] -> Package[$server_package]
    }

    if $puppet::server::manage_user {
      Package[$server_package] -> User[$puppet::server::user]
    }
  }
}
