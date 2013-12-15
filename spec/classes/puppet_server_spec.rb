require 'spec_helper'

describe 'puppet::server' do

  let :pre_condition do
    "class {'puppet': server => true}"
  end

  let :facts do {
    :concat_basedir         => '/nonexistant',
    :clientcert             => 'puppetmaster.example.com',
    :fqdn                   => 'puppetmaster.example.com',
    :operatingsystemrelease => '6.5',
    :osfamily               => 'RedHat',
  } end

  describe 'with no custom parameters' do
    it 'should include classes' do
      should contain_class('puppet::server::install')
      should contain_class('puppet::server::config')
      should contain_class('puppet::server::service')
    end
  end

end
