# Set up the puppet config
class puppet::config {
  case $::puppet::runmode {
    'service': {
      $runmode_class = 'daemon'
    }
    'cron': {
      $runmode_class = 'cron'
    }
    default: {
      fail("Runmode of ${puppet::runmode} not supported by puppet::config!")
    }
  }

  $ca_server = $::puppet::ca_server
  file { $puppet::dir:
    ensure => directory,
  } ->
  file { "${puppet::dir}/puppet.conf":
    content => template($puppet::agent_template),
  } ~>
  file { "${puppet::dir}/auth.conf":
    content => template($puppet::auth_template),
  } ~>
  class { "::puppet::${runmode_class}": } ~>
  Class['::puppet::service']

  if $puppet::listen {
    file { "${puppet::dir}/namespaceauth.conf":
      content => template($puppet::nsauth_template),
      notify  => Class["::puppet::${runmode_class}", '::puppet::service'],
    }
  }
}
