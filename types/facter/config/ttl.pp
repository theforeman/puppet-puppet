# @summary Facter `facts.ttls` ttl value type
type Puppet::Facter::Config::TTL = Variant[
  Integer[0],
  # See STRING_TO_SECONDS and ttls_to_seconds() in
  # https://github.com/OpenVoxProject/openfact/blob/main/lib/facter/framework/config/fact_groups.rb
  Pattern[/^\d+( +(ns|nano(s)?|nanosecond(s)?|us|micro(s)?|microsecond(s)?|ms|mili(s)?|millisecond(s)?|s|second(s)?|m|minute(s)?|h|hour(s)?|d|day(s)?))?$/]
]
