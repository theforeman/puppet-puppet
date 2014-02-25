require 'spec_helper'

describe 'puppet::config' do
  let :facts do {
    :osfamily => 'RedHat',
  } end

  describe 'with default parameters' do
    let :pre_condition do
      'include ::puppet'
    end

    it 'should contain auth.conf' do
      should contain_file('/etc/puppet/auth.conf').with_content(%r{^path /certificate_revocation_list/ca\nmethod find$})
    end
  end
end
