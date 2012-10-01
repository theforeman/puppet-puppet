class puppet::config {
  file { $puppet::dir:
    ensure => directory,
  }
    file { "${puppet::dir}/puppet.conf":
    content => template("$puppet::agent_template"),
  }

}
