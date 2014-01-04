require 'spec_helper'

describe 'puppet::server::env' do

  let :facts do
    {
      :osfamily   => 'RedHat',
      :fqdn       => 'puppetmaster.example.com',
      :clientcert => 'puppetmaster.example.com',
    }
  end

  let(:title) { 'foo' }

  describe 'with no custom parameters' do
    let :pre_condition do
      "class {'puppet': server => true}"
    end

    it { should compile.with_all_deps }
    it { should contain_puppet__server__env('foo').with({
        :basedir        => '/etc/puppet/environments',
        :config_version => nil,
        :manifest       => nil,
        :manifestdir    => nil,
        :modulepath     => [
          '/etc/puppet/environments/foo/modules',
          '/etc/puppet/environments/common',
          '/usr/share/puppet/modules',
        ],
    }) }
  end

  describe 'with server_config_version set' do
    let :pre_condition do
      "class {'puppet': server => true, server_config_version => 'bar' }"
    end

    it { should compile.with_all_deps }
    it { should contain_puppet__server__env('foo').with({
        :basedir        => '/etc/puppet/environments',
        :config_version => 'bar',
        :manifest       => nil,
        :manifestdir    => nil,
        :modulepath     => [
          '/etc/puppet/environments/foo/modules',
          '/etc/puppet/environments/common',
          '/usr/share/puppet/modules',
        ],
    }) }
  end

end
