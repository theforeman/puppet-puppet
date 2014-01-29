require 'spec_helper'

describe 'puppet::server::env' do
  
  let(:title) { 'foo' }

  let :facts do {
    :clientcert             => 'puppetmaster.example.com',
    :concat_basedir         => '/nonexistant',
    :fqdn                   => 'puppetmaster.example.com',
    :rubyversion            => '1.9.3',
    :operatingsystemrelease => '6.5',
    :osfamily               => 'RedHat',
  } end

  context 'with no custom parameters' do
    let :pre_condition do
      "class {'puppet': server => true}"
    end

    it 'should add an env section' do
      should contain_file('/etc/puppet/environments/foo').with({
        :ensure => 'directory',
      })

      should contain_file('/etc/puppet/environments/foo/modules').with({
        :ensure => 'directory',
      })

      should contain_concat_fragment('puppet.conf+40-foo').
        without_content(/^\s+manifest\s+=/).
        without_content(/^\s+manifestdir\s+=/).
        with_content(%r{^\s+modulepath\s+= /etc/puppet/environments/foo/modules:/etc/puppet/environments/common:/usr/share/puppet/modules$}).
        without_content(/^\s+templatedir\s+=/).
        with_content(/^\s+config_version\s+=/).
        with({}) # So we can use a trailing dot on each with_content line
    end

  end

  context 'with server_config_version' do
    let :pre_condition do
      "class {'puppet': server => true, server_config_version => 'bar'}"
    end

    it 'should add an env section' do
      should contain_file('/etc/puppet/environments/foo').with({
        :ensure => 'directory',
      })

      should contain_file('/etc/puppet/environments/foo/modules').with({
        :ensure => 'directory',
      })

      should contain_concat_fragment('puppet.conf+40-foo').
        without_content(/^\s+manifest\s+=/).
        without_content(/^\s+manifestdir\s+=/).
        with_content(%r{^\s+modulepath\s+= /etc/puppet/environments/foo/modules:/etc/puppet/environments/common:/usr/share/puppet/modules$}).
        without_content(/^\s+templatedir\s+=/).
        with_content(/^\s+config_version\s+= bar/).
        with({}) # So we can use a trailing dot on each with_content line
    end

  end

  context 'with config_version' do
    let :pre_condition do
      "class {'puppet': server => true, server_config_version => 'bar'}"
    end

    let :params do
      {
        :config_version => 'bar',      
      }
    end

    it 'should add an env section' do
      should contain_file('/etc/puppet/environments/foo').with({
        :ensure => 'directory',
      })

      should contain_file('/etc/puppet/environments/foo/modules').with({
        :ensure => 'directory',
      })

      should contain_concat_fragment('puppet.conf+40-foo').
        without_content(/^\s+manifest\s+=/).
        without_content(/^\s+manifestdir\s+=/).
        with_content(%r{^\s+modulepath\s+= /etc/puppet/environments/foo/modules:/etc/puppet/environments/common:/usr/share/puppet/modules$}).
        without_content(/^\s+templatedir\s+=/).
        with_content(/^\s+config_version\s+= bar/).
        with({}) # So we can use a trailing dot on each with_content line
    end

  end

end
