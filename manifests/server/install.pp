class puppet::server::install {

  package { $puppet::params::master_package: ensure => installed }

}
