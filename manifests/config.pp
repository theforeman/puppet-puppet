# Set up the puppet config
class puppet::config(
  $allow_any_crl_auth = $::puppet::allow_any_crl_auth,
  $auth_allowed       = $::puppet::auth_allowed,
  $auth_template      = $::puppet::auth_template,
  $ca_server          = $::puppet::ca_server,
  $ca_port            = $::puppet::ca_port,
  $dns_alt_names      = $::puppet::dns_alt_names,
  $hiera_config       = $::puppet::hiera_config,
  $listen_to          = $::puppet::listen_to,
  $main_template      = $::puppet::main_template,
  $module_repository  = $::puppet::module_repository,
  $nsauth_template    = $::puppet::nsauth_template,
  $pluginsource       = $::puppet::pluginsource,
  $pluginfactsource   = $::puppet::pluginfactsource,
  $puppet_dir         = $::puppet::dir,
  $puppetmaster       = $::puppet::puppetmaster,
  $syslogfacility     = $::puppet::syslogfacility,
  $srv_domain         = $::puppet::srv_domain,
  $use_srv_records    = $::puppet::use_srv_records,
) {
  concat::fragment { 'puppet.conf+10-main':
    target  => "${puppet_dir}/puppet.conf",
    content => template($main_template),
    order   => '10',
  }

  file { $puppet_dir:
    ensure => directory,
    owner  => $::puppet::dir_owner,
    group  => $::puppet::dir_group,
  } ->
  case $::osfamily {
    'Windows': {
      concat { "${puppet_dir}/puppet.conf": }
    }

    default: {
      concat { "${puppet_dir}/puppet.conf":
        owner => 'root',
        group => $::puppet::params::root_group,
        mode  => '0644',
      }
    }
  } ~>
  file { "${puppet_dir}/auth.conf":
    content => template($auth_template),
  }

  if $puppet::listen {
    file { "${puppet_dir}/namespaceauth.conf":
      content => template($nsauth_template),
    }
  }

  # only manage this file if we provide content
  if $puppet::server_default_manifest and $puppet::server_default_manifest_content != '' {
    file { $::puppet::server_default_manifest_path:
      ensure  => file,
      owner   => $puppet::user,
      group   => $puppet::group,
      mode    => '0644',
      content => $puppet::server_default_manifest_content,
    }
  }

}
