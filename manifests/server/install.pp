class puppet::server::install {

  package { $puppet::server::master_package: ensure => installed }

}
