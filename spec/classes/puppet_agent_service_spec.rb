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

    it 'should enable daemon' do
      should contain_service('puppet').with({
        :ensure     => 'running',
        :name       => 'puppet',
        :hasstatus  => 'true',
        :enable     => 'true',
      })
    end

    it 'should disable cron' do
      should contain_cron('puppet').with_ensure('absent')
    end

    it 'should disable systemd timer' do
      should contain_service('puppetcron.timer').with({
        :provider => 'systemd',
        :ensure   => 'stopped',
        :name     => 'puppetcron.timer',
        :enable   => 'false',
      })

      should contain_file('/etc/systemd/system/puppetcron.timer').with_ensure(:absent)
      should contain_file('/etc/systemd/system/puppetcron.service').with_ensure(:absent)

      should contain_exec('systemctl-daemon-reload').with({
        :refreshonly => true,
        :command     => 'systemctl daemon-reload',
      })
    end
  end

  describe 'when runmode => cron' do
    let :pre_condition do
      "class {'puppet': agent => true, runmode => 'cron'}"
    end

    it 'should disable daemon' do
      should contain_service('puppet').with({
        :ensure     => 'stopped',
        :name       => 'puppet',
        :hasstatus  => 'true',
        :enable     => 'false',
      })
    end

    it 'should enable cron' do
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

    it 'should disable systemd timer' do
      should contain_service('puppetcron.timer').with({
        :provider => 'systemd',
        :ensure   => 'stopped',
        :name     => 'puppetcron.timer',
        :enable   => 'false',
      })

      should contain_file('/etc/systemd/system/puppetcron.timer').with_ensure(:absent)
      should contain_file('/etc/systemd/system/puppetcron.service').with_ensure(:absent)

      should contain_exec('systemctl-daemon-reload').with({
        :refreshonly => true,
        :command     => 'systemctl daemon-reload',
      })
    end
  end

  describe 'when runmode => systemd.timer' do
    let :pre_condition do
      "class {'puppet': agent => true, runmode => 'systemd.timer'}"
    end

    it 'should disable daemon' do
      should contain_service('puppet').with({
        :ensure     => 'stopped',
        :name       => 'puppet',
        :hasstatus  => 'true',
        :enable     => 'false',
      })
    end

    it 'should disable cron' do
      should contain_cron('puppet').with_ensure('absent')
    end

    it 'should enable systemd timer' do
      if Puppet.version < '4.0'
        confdir = '/etc/puppet'
      else
        confdir = '/etc/puppetlabs/puppet'
      end

      should contain_file('/etc/systemd/system/puppetcron.timer')
        .with_content(/.*OnCalendar\=\*\:15,45.*/)
      should contain_file('/etc/systemd/system/puppetcron.service')
        .with_content(/.*ExecStart=\/usr\/bin\/env puppet agent --config #{confdir}\/puppet.conf --onetime --no-daemonize.*/)

      should contain_exec('systemctl-daemon-reload').with({
        :refreshonly => true,
        :command     => 'systemctl daemon-reload',
      })

      should contain_service('puppetcron.timer').with({
        :provider => 'systemd',
        :ensure   => 'running',
        :name     => 'puppetcron.timer',
        :enable   => 'true',
      })
    end
  end

  describe 'when runmode => none' do
    let :pre_condition do
      "class {'puppet': agent => true, runmode => 'none'}"
    end

    it 'should disable daemon' do
      should contain_service('puppet').with({
        :ensure     => 'stopped',
        :name       => 'puppet',
        :hasstatus  => 'true',
        :enable     => 'false',
      })
    end

    it 'should disable cron' do
      should contain_cron('puppet').with_ensure('absent')
    end

    it 'should disable systemd timer' do
      should contain_service('puppetcron.timer').with({
        :provider => 'systemd',
        :ensure   => 'stopped',
        :name     => 'puppetcron.timer',
        :enable   => 'false',
      })

      should contain_file('/etc/systemd/system/puppetcron.timer').with_ensure(:absent)
      should contain_file('/etc/systemd/system/puppetcron.service').with_ensure(:absent)

      should contain_exec('systemctl-daemon-reload').with({
        :refreshonly => true,
        :command     => 'systemctl daemon-reload',
      })
    end

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
