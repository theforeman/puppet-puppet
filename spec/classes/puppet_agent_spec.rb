require 'spec_helper'

describe 'puppet::agent' do

  let :default_facts do
    {
        :clientcert => 'puppetmaster.example.com',
        :concat_basedir => '/nonexistant',
        :fqdn => 'puppetmaster.example.com',
        :operatingsystemrelease => '6.5',
        :osfamily => 'RedHat',
    }
  end

  let :facts do
    default_facts
  end

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

    it do
      should contain_concat_fragment('puppet.conf+20-agent').
                 with_content(/server.*puppetmaster\.example\.com/)
    end
  end

  describe 'puppetmaster parameter overrides server fqdn' do
    let(:pre_condition) { "class {'puppet': agent => true, puppetmaster => 'mymaster.example.com'}" }
    it do
      should contain_concat_fragment('puppet.conf+20-agent').
                 with_content(/server.*mymaster\.example\.com/)
    end
  end

  describe 'global puppetmaster overrides fqdn' do
    let(:pre_condition) { "class {'puppet': agent => true}" }
    let :facts do
      default_facts.merge({:puppetmaster => 'mymaster.example.com'})
    end
    it do
      should contain_concat_fragment('puppet.conf+20-agent').
                 with_content(/server.*mymaster\.example\.com/)
    end
  end

  describe 'puppetmaster parameter overrides global puppetmaster' do
    let(:pre_condition) { "class {'puppet': agent => true, puppetmaster => 'mymaster.example.com'}" }
    let :facts do
      default_facts.merge({:puppetmaster => 'global.example.com'})
    end
    it do
      should contain_concat_fragment('puppet.conf+20-agent').
                 with_content(/server.*mymaster\.example\.com/)
    end
  end

  describe 'use_srv_records removes server setting' do
    let(:pre_condition) { "class {'puppet': agent => true, use_srv_records => true}" }
    it do
      should contain_concat_fragment('puppet.conf+20-agent').
                 without_content(/server\s*=/)
    end
  end
end

