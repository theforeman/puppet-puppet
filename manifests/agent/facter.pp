# Manage Facter/Openfact configuration
# @param config_dir
#   Override configuration directory
# @param config_file
#   Override configuration file name
# @param config
#   Override configuration
class puppet::agent::facter (
  Stdlib::Absolutepath $config_dir = $puppet::facter_config_dir,
  String[1] $config_file = 'facter.conf',
  Puppet::Facter::Config $config = $puppet::facter_config,
) {
  $config_text = @("CONFIG")
    # Managed by Puppet
    ${config.stdlib::to_json_pretty()}
    |-CONFIG

  file { $config_dir:
    ensure => 'directory',
  }

  file { "${config_dir}/${config_file}":
    ensure  => 'file',
    content => $config_text,
  }
}
