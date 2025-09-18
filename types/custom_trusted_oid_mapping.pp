# @summary A type for custom trusted OID mappings
#
# This type defines the structure for custom trusted OID mappings used in Puppet's
# trusted facts system. It allows mapping custom OIDs to human-readable names.
#
# @example Basic usage
#   $custom_oids = {
#     '1.3.6.1.4.1.34380.1.2.1.1' => {
#       'shortname' => 'pp_role',
#       'longname'  => 'Puppet Role'
#     }
#   }
#
# @example Multiple OID mappings
#   $custom_oids = {
#     '1.3.6.1.4.1.34380.1.1.13' => {
#       'shortname' => 'pp_environment'
#     },
#     '1.3.6.1.4.1.34380.1.1.24' => {
#       'shortname' => 'pp_datacenter',
#       'longname'  => 'Puppet Datacenter'
#     }
#   }
type Puppet::Custom_trusted_oid_mapping = Hash[String, Struct[{ shortname => String, longname  => Optional[String], }]]
