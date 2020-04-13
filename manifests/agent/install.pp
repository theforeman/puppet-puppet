# Install the puppet agent package
# @api private
class puppet::agent::install(
  $manage_packages = $puppet::manage_packages,
  $package_name = $puppet::client_package,
  $package_version = $puppet::version,
  $package_provider = $puppet::package_provider,
  $package_source = $puppet::package_source,
) {
  if $manage_packages == true or $manage_packages == 'agent' {
    package { $package_name:
      ensure   => $package_version,
      provider => $package_provider,
      source   => $package_source,
    }
  }
}
