require 'spec_helper'

describe 'puppet::server::service' do

  let :facts do {
    :clientcert             => 'puppetmaster.example.com',
    :concat_basedir         => '/nonexistant',
    :fqdn                   => 'puppetmaster.example.com',
    :operatingsystemrelease => '6.5',
    :osfamily               => 'RedHat',
  } end

  describe 'default_parameters' do
    it do
      should contain_service('puppetmaster').with({
        :ensure => 'running',
        :enable => 'true',
      })
    end

    it do
      should contain_service('puppetserver').with({
        :ensure => 'stopped',
        :enable => 'false',
      })
    end
  end

  describe 'when puppetserver => true' do
    let(:params) { {:puppetserver => true, :puppetmaster => false} }
    it do
      should contain_service('puppetserver').with({
        :ensure => 'running',
        :enable => 'true',
      })
    end

    it do
      should contain_service('puppetmaster').with({
        :ensure => 'stopped',
        :enable => 'false',
      })
    end
  end

  describe 'when puppetserver => true' do
    let(:params) { {:puppetserver => true, :puppetmaster => true} }
    it { expect { should create_class('puppet::server::service') }.to raise_error(Puppet::Error, /Both puppetmaster and puppetserver cannot be enabled simultaneously/) }
  end

end
