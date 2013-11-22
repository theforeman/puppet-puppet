# Set up the puppet config
class puppet::config {
  concat_build { 'puppet.conf': }
  concat_fragment { 'puppet.conf+10-main':
    content => template($puppet::main_template),
  }

  $ca_server = $::puppet::ca_server
  file { $puppet::dir:
    ensure => directory,
  } ->
  file { "${puppet::dir}/puppet.conf":
    source  => concat_output('puppet.conf'),
    require => Concat_build['puppet.conf'],
  } ~>
  file { "${puppet::dir}/auth.conf":
    content => template($puppet::auth_template),
  }

  if $puppet::listen {
    file { "${puppet::dir}/namespaceauth.conf":
      content => template($puppet::nsauth_template),
    }
  }
}
