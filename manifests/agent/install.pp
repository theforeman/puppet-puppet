# Install the puppet client installation
class puppet::agent::install {
  if $::puppet::manage_packages == true or $::puppet::manage_packages == 'agent' {
    package { $::puppet::client_package:
      ensure   => $::puppet::version,
      provider => $::puppet::package_provider,
      source   => $::puppet::package_source,
    }
  }
}
