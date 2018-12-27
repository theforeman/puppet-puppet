# Set up the puppet server as a service
#
# @param $enable Whether to enable the service or not
# @param $service_name The service name to manage
#
# @api private
class puppet::server::service(
  Boolean $enable = true,
  String $service_name = 'puppetserver',
) {
  service { $service_name:
    ensure => $enable,
    enable => $enable,
  }
}
