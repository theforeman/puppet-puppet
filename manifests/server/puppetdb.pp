# @summary PuppetDB integration
#
# This class relies on the puppetlabs/puppetdb and essentially wraps
# puppetdb::master::config with the proper resource chaining.
#
# Note that this doesn't manage the server itself.
#
# @example
#   class { 'puppet':
#     server              => true,
#     server_reports      => 'puppetdb,foreman',
#     server_storeconfigs => true,
#   }
#   class { 'puppet::server::puppetdb':
#     server => 'mypuppetdb.example.com',
#   }
#
# @param server
#   The PuppetDB server
#
# @param port
#   The PuppetDB port
#
# @param soft_write_failure
#   Whether to enable soft write failure
#
# @param terminus_package
#   The PuppetDB terminus package
#
class puppet::server::puppetdb (
  Stdlib::Host $server = undef,
  Stdlib::Port $port = 8081,
  Boolean $soft_write_failure = false,
  Optional[String[1]] $terminus_package = undef,
) {
  class { 'puppetdb::master::config':
    puppetdb_server             => $server,
    puppetdb_port               => $port,
    puppetdb_soft_write_failure => $soft_write_failure,
    manage_storeconfigs         => false,
    restart_puppet              => false,
    terminus_package            => $terminus_package,
  }
  Class['puppetdb::master::puppetdb_conf'] ~> Class['puppet::server::service']
}
