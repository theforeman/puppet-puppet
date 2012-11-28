class puppet::server::install {

  package { $puppet::server::master_package: ensure => $::puppet::server::version  }

}
