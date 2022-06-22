# Install the puppet agent package
# @api private
class puppet::agent::install (
  Variant[Boolean, Enum['server', 'agent']] $manage_packages = $puppet::manage_packages,
  Variant[String, Array[String]] $package_name = $puppet::client_package,
  String[1] $package_version = $puppet::version,
  Optional[String[1]] $package_provider = $puppet::package_provider,
  Variant[Undef, String, Hash, Array] $package_install_options = $puppet::package_install_options,
  Variant[Undef, Stdlib::Absolutepath, Stdlib::HTTPUrl] $package_source = $puppet::package_source,
) {
  if $manage_packages == true or $manage_packages == 'agent' {
    package { $package_name:
      ensure          => $package_version,
      provider        => $package_provider,
      install_options => $package_install_options,
      source          => $package_source,
    }
  }
}
