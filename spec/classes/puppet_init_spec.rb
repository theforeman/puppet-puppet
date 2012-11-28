require 'spec_helper'

describe 'puppet' do

  let(:pre_condition) { "class foreman::params { }" }
  let(:facts) do
    {
      :fqdn => 'puppetmaster.example.com',
      :clientcert => 'puppetmaster.example.com',
    }
  end

  describe 'with no custom parameters' do
    it { should include_class('puppet::install') }
    it { should include_class('puppet::config') }
    it { should contain_file('/etc/puppet').with_ensure('directory') }
    it { should contain_file('/etc/puppet/puppet.conf') }
    it { should contain_package('puppet').with_ensure('present') }
  end

end
