# Install the puppet client installation
class puppet::install {

  package { $puppet::params::client_package:
    ensure => $::puppet::version,
  }

}
