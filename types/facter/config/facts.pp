# @summary Facter `facts` configuration type
type Puppet::Facter::Config::Facts = Struct[{
    Optional['blocklist'] => Array[String[1]],
    Optional['ttls'] => Array[Hash[String[1], Puppet::Facter::Config::TTL]],
}]
