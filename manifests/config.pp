# Set up the puppet config
class puppet::config(
  $allow_any_crl_auth  = $::puppet::allow_any_crl_auth,
  $auth_allowed        = $::puppet::auth_allowed,
  $auth_template       = $::puppet::auth_template,
  $ca_server           = $::puppet::ca_server,
  $ca_port             = $::puppet::ca_port,
  $dns_alt_names       = $::puppet::dns_alt_names,
  $listen_to           = $::puppet::listen_to,
  $main_template       = $::puppet::main_template,
  $module_repository   = $::puppet::module_repository,
  $pluginsource        = $::puppet::pluginsource,
  $pluginfactsource    = $::puppet::pluginfactsource,
  $puppet_dir          = $::puppet::dir,
  $puppetmaster        = $::puppet::puppetmaster,
  $syslogfacility      = $::puppet::syslogfacility,
  $srv_domain          = $::puppet::srv_domain,
  $use_srv_records     = $::puppet::use_srv_records,
  $additional_settings = $::puppet::additional_settings,
) {
  puppet::config::main{
    'vardir': value => $::puppet::vardir;
    'logdir': value => $::puppet::logdir;
    'rundir': value => $::puppet::rundir;
    'ssldir': value => $::puppet::ssldir;
    'privatekeydir': value => '$ssldir/private_keys { group = service }';
    'hostprivkey': value => '$privatekeydir/$certname.pem { mode = 640 }';
    'show_diff': value  => $::puppet::show_diff;
  }

  if $module_repository and !empty($module_repository) {
    puppet::config::main{'module_repository': value => $module_repository; }
  }
  if $ca_server and !empty($ca_server) {
    puppet::config::main{'ca_server': value => $ca_server; }
  }
  if $ca_port and !empty($ca_port) {
    puppet::config::main{'ca_port': value => $ca_port; }
  }
  if $dns_alt_names and !empty($dns_alt_names) {
    puppet::config::main{'dns_alt_names': value => $dns_alt_names; }
  }
  if $use_srv_records {
    unless $srv_domain {
      fail('$::domain fact found to be undefined and $srv_domain is undefined')
    }
    puppet::config::main{
      'use_srv_records': value => true;
      'srv_domain': value => $srv_domain;
    }
  }
  if $pluginsource {
    puppet::config::main{'pluginsource': value => $pluginsource; }
  }
  if $pluginfactsource {
    puppet::config::main{'pluginfactsource': value => $pluginfactsource; }
  }
  if $syslogfacility and !empty($syslogfacility) {
    puppet::config::main{'syslogfacility': value => $syslogfacility; }
  }

  # we need to store this in a variable, because older puppet doesn't
  # like resource{function(): ... }
  $additional_settings_keys = keys($additional_settings)
  puppet::config::additional_settings{ $additional_settings_keys:
    hash     => $additional_settings,
    resource => '::puppet::config::main',
  }

  file { $puppet_dir:
    ensure => directory,
    owner  => $::puppet::dir_owner,
    group  => $::puppet::dir_group,
  }
  -> case $::osfamily {
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
  }
  ~> file { "${puppet_dir}/auth.conf":
    content => template($auth_template),
  }
}
