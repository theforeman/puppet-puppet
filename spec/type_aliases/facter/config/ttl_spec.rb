require 'spec_helper'

describe 'Puppet::Facter::Config::TTL' do
  [
    'ns',
    'nano',
    'nanos',
    'nanosecond',
    'nanoseconds',
    'us',
    'micro',
    'micros',
    'microsecond',
    'microseconds',
    'ms',
    'mili',
    'milis',
    'millisecond',
    'milliseconds',
    's',
    'second',
    'seconds',
    'm',
    'minute',
    'minutes',
    'h',
    'hours',
    'd',
    'day',
    'days',
  ].each do |t|
    it { is_expected.to allow_value("123 #{t}") }
  end
end
