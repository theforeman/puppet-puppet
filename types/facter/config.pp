# @summary Facter configuration type
type Puppet::Facter::Config = Struct[{
    Optional['facts']       => Puppet::Facter::Config::Facts,
    Optional['global']      => Puppet::Facter::Config::Global,
    Optional['cli']         => Puppet::Facter::Config::CLI,
    Optional['fact-groups'] => Hash[String[1], Array[String[1]]],
}]
