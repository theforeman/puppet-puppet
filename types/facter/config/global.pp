# @summary Facter `global` configuration type
#
# @note Options below cannot be `true` when using Facter/Openfact with Puppet/OpenVox:
#   * `no-custom-facts`
#   * `no-ruby`
type Puppet::Facter::Config::Global = Struct[{
    Optional['external-dir']      => Array[Stdlib::Absolutepath],
    Optional['custom-dir']        => Array[Stdlib::Absolutepath],
    Optional['no-external-facts'] => Boolean,
    Optional['no-custom-facts']   => Boolean[false], # Cannot be true
    Optional['no-ruby']           => Boolean[false], # Cannot be true
}]
