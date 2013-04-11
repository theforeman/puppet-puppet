# Set up the puppet config
class puppet::config {
  file { $puppet::dir:
    ensure => directory,
  }

  file { "${puppet::dir}/puppet.conf":
    content => template($puppet::agent_template),
  }

  file { "${puppet::dir}/auth.conf":
    content => template($puppet::auth_template),
  }

  if $puppet::listen {
    file { "${puppet::dir}/namespaceauth.conf":
      content => template($puppet::nsauth_template),
    }
  }

  case $::puppet::runmode {
    'service': {
      include ::puppet::daemon
    }
    'cron': {
      include ::puppet::cron
    }
    default: {
      fail("Runmode of ${puppet::runmode} not supported by puppet::config!")
    }
  }
}
