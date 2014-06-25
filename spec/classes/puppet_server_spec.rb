require 'spec_helper'

describe 'puppet::server' do

  context 'basic case' do
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

  context 'with uppercase hostname' do
    let :pre_condition do
      "class {'puppet': server => true}"
    end

    let :facts do {
      :concat_basedir         => '/nonexistant',
      :clientcert             => 'PUPPETMASTER.example.com',
      :fqdn                   => 'PUPPETMASTER.example.com',
      :operatingsystemrelease => '6.5',
      :osfamily               => 'RedHat',
    } end

    describe 'with no custom parameters' do
      it 'should use lowercase certificates' do
        should contain_class('puppet::server::passenger').
          with_ssl_cert('/var/lib/puppet/ssl/certs/puppetmaster.example.com.pem').
          with_ssl_cert_key('/var/lib/puppet/ssl/private_keys/puppetmaster.example.com.pem')
      end
    end
  end
end
