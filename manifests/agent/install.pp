# Install the puppet client installation
class puppet::agent::install {

  package { $puppet::params::client_package:
    ensure => $::puppet::version,
  }

}
