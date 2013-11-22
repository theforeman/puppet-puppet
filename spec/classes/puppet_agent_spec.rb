require 'spec_helper'

describe 'puppet::agent' do

  let(:facts) do
    {
      :fqdn => 'puppetmaster.example.com',
      :clientcert => 'puppetmaster.example.com',
      :osfamily => 'RedHat',
    }
  end

  describe 'with no custom parameters' do
    let :pre_condition do
      "class {'puppet': agent => true}"
    end
    it { should include_class('puppet::agent::install') }
    it { should include_class('puppet::agent::config') }
    it { should include_class('puppet::agent::service') }
    it { should contain_file('/etc/puppet').with_ensure('directory') }
    it { should contain_file('/etc/puppet/puppet.conf') }
    it { should contain_package('puppet').with_ensure('present') }
  end

end

