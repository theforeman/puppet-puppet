require 'spec_helper'

describe 'puppet::agent::service' do

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

    it do
      should contain_service('puppet').with({
        :ensure     => 'running',
        :name       => 'puppet',
        :hasstatus  => 'true',
        :enable     => 'true',
      })
    end

    it { should contain_cron('puppet').with_ensure('absent') }
  end

  describe 'when runmode => cron' do
    let :pre_condition do
      "class {'puppet': agent => true, runmode => 'cron'}"
    end

    it do
      should contain_service('puppet').with({
        :ensure     => 'stopped',
        :name       => 'puppet',
        :hasstatus  => 'true',
        :enable     => 'false',
      })
    end

    it do
      should contain_cron('puppet').with({
        :command  => '/usr/bin/env puppet agent --config /etc/puppet/puppet.conf --onetime --no-daemonize',
        :user     => 'root',
        :minute   => ['0','30'],
        :hour     => '*',
      })
    end
  end

  describe 'when runmode => none' do
    let :pre_condition do
      "class {'puppet': agent => true, runmode => 'none'}"
    end

    it do
      should contain_service('puppet').with({
        :ensure     => 'stopped',
        :name       => 'puppet',
        :hasstatus  => 'true',
        :enable     => 'false',
      })
    end

    it { should contain_cron('puppet').with_ensure('absent') }
  end

  describe 'when runmode => foo' do
    let :pre_condition do
      "class {'puppet': agent => true, runmode => 'foo'}"
    end

    it { expect { should create_class('puppet::agent::service') }.to raise_error(Puppet::Error, /Runmode of foo not supported by puppet::agent::config!/) }
  end

end
