# Install the puppet agent package
#
# @summary Installs the Puppet agent package
#
# This class handles the installation of the Puppet agent package with
# configurable package name, version, provider, and installation options.
#
# @param manage_packages
#   Whether to manage packages. Can be true, false, 'server', or 'agent'.
#   When true or 'agent', the agent package will be installed.
#
# @param package_name
#   The name of the puppet client package(s) to install.
#   Can be a string or array of package names.
#
# @param package_version
#   The version of the puppet package to install.
#
# @param package_provider
#   The package provider to use for installation (e.g., 'yum', 'apt', 'chocolatey').
#
# @param package_install_options
#   Additional options to pass to the package installation command.
#   Can be a string, hash, or array depending on the provider.
#
# @param package_source
#   The source location for the package. Can be a local path or HTTP URL.
#
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
