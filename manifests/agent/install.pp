# Install the puppet client installation
class puppet::agent::install {
  package { $puppet::client_package:
    ensure   => $::puppet::version,
    provider => $::puppet::package_provider,
  }
}
