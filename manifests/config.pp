class puppet::config {
  file { $puppet::params::dir:
    ensure => directory,
  }
    file { "${puppet::params::dir}/puppet.conf":
    content => template("$puppet::params::agent_template"),
  }

}
