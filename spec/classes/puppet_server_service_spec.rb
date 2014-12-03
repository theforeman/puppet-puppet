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
    it { should_not contain_service('puppetmaster') }
    it { should_not contain_service('puppetserver') }
  end

  describe 'when puppetmaster => true' do
    let(:params) { {:puppetmaster => true, :puppetserver => Undef.new} }
    it do
      should contain_service('puppetmaster').with({
        :ensure => 'running',
        :enable => 'true',
      })
    end
  end

  describe 'when puppetserver => true' do
    let(:params) { {:puppetserver => true, :puppetmaster => Undef.new} }
    it do
      should contain_service('puppetserver').with({
        :ensure => 'running',
        :enable => 'true',
      })
    end
  end

  describe 'when puppetmaster => false' do
    let(:params) { {:puppetmaster => false} }
    it do
      should contain_service('puppetmaster').with({
        :ensure => 'stopped',
        :enable => 'false',
      })
    end
  end

  describe 'when puppetserver => false' do
    let(:params) { {:puppetserver => false} }
    it do
      should contain_service('puppetserver').with({
        :ensure => 'stopped',
        :enable => 'false',
      })
    end
  end

  describe 'when puppetmaster => undef' do
    let(:params) { {:puppetmaster => Undef.new} }
    it { should_not contain_service('puppetmaster') }
  end

  describe 'when puppetserver => undef' do
    let(:params) { {:puppetserver => Undef.new} }
    it { should_not contain_service('puppetserver') }
  end

  describe 'when puppetmaster => true and puppetserver => true' do
    let(:params) { {:puppetserver => true, :puppetmaster => true} }
    it { should raise_error(Puppet::Error, /Both puppetmaster and puppetserver cannot be enabled simultaneously/) }
  end

end
