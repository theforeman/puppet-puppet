require 'spec_helper'

describe 'puppet::agent::service' do

  if Puppet.version < '4.0'
    additional_facts = {}
  else
    additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
  end

  let :facts do on_supported_os['centos-6-x86_64'].merge({
    :clientcert     => 'puppetmaster.example.com',
    :concat_basedir => '/nonexistant',
    :fqdn           => 'puppetmaster.example.com',
    :puppetversion  => Puppet.version,
  }).merge(additional_facts) end

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
      if Puppet.version < '4.0'
        confdir = '/etc/puppet'
      else
        confdir = '/etc/puppetlabs/puppet'
      end
      should contain_cron('puppet').with({
        :command  => "/usr/bin/env puppet agent --config #{confdir}/puppet.conf --onetime --no-daemonize",
        :user     => 'root',
        :minute   => ['15','45'],
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

    it { should raise_error(Puppet::Error, /Runmode of foo not supported by puppet::agent::config!/) }
  end

  describe 'with custom service_name' do
    let :pre_condition do
      "class {'puppet': agent => true, service_name => 'pe-puppet'}"
    end

    it do
      should contain_service('puppet').with({
        :ensure     => 'running',
        :name       => 'pe-puppet',
        :hasstatus  => 'true',
        :enable     => 'true',
      })
    end

  end

end
