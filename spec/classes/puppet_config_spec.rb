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

  describe 'with allow_any_crl_auth' do
    let :pre_condition do
      'class {"::puppet": allow_any_crl_auth => true}'
    end

    it 'should contain auth.conf with auth any' do
      should contain_file('/etc/puppet/auth.conf').with_content(%r{^path /certificate_revocation_list/ca\nauth any$})
    end
  end
end
