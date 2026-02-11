# @summary Facter `cli` configuration type
#
# @note All these settings are ignored when called from the Ruby API (by Puppet/OpenVox)
type Puppet::Facter::Config::CLI = Struct[{
    Optional['debug']     => Boolean,
    Optional['trace']     => Boolean,
    Optional['verbose']   => Boolean,
    Optional['log-level'] => Enum['none','trace','debug','info','warn','error','fatal'],
}]
