# Set up the puppet config
class puppet::config(
  $allow_any_crl_auth = $::puppet::allow_any_crl_auth,
  $auth_template      = $::puppet::auth_template,
  $ca_server          = $::puppet::ca_server,
  $main_template      = $::puppet::main_template,
  $nsauth_template    = $::puppet::nsauth_template,
  $puppet_dir         = $::puppet::dir,
  $user               = $::puppet::user,
  $group              = $::puppet::group,
) {
  concat_build { 'puppet.conf': }
  concat_fragment { 'puppet.conf+10-main':
    content => template($main_template),
  }

  file { $puppet_dir:
    ensure => directory,
  } ->
  file { "${puppet_dir}/puppet.conf":
    source  => concat_output('puppet.conf'),
    require => Concat_build['puppet.conf'],
    owner   => $user,
    group   => $group,
    mode    => '0644',
  } ~>
  file { "${puppet_dir}/auth.conf":
    content => template($auth_template),
  }

  if $puppet::listen {
    file { "${puppet_dir}/namespaceauth.conf":
      content => template($nsauth_template),
    }
  }
}
