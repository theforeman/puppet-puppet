require 'spec_helper'

describe 'puppet::agent' do

  let :facts do {
    :clientcert             => 'puppetmaster.example.com',
    :concat_basedir         => '/nonexistant',
    :fqdn                   => 'puppetmaster.example.com',
    :operatingsystemrelease => '6.5',
    :osfamily               => 'RedHat',
  } end

  describe 'with no custom parameters' do
    let :pre_condition do
      "class {'puppet': agent => true}"
    end
    it { should contain_class('puppet::agent::install') }
    it { should contain_class('puppet::agent::config') }
    it { should contain_class('puppet::agent::service') }
    it { should contain_file('/etc/puppet').with_ensure('directory') }
    it { should contain_file('/etc/puppet/puppet.conf') }
    it { should contain_package('puppet').with_ensure('present') }
    it do
      should contain_concat_fragment('puppet.conf+20-agent').
        with_content(/^\[agent\]/).
        with({})
    end
  end

end

