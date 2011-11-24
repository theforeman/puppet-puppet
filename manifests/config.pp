class puppet::config {
  file {
    $puppet::params::dir: ensure => directory;
    "${puppet::params::dir}/puppet.conf": content => template("puppet/puppet.conf.erb");
  }
  
}
