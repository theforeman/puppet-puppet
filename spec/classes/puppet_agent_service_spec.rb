require 'spec_helper'

describe 'puppet::agent::service' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :clientcert     => 'puppetmaster.example.com',
          :concat_basedir => '/nonexistant',
          :fqdn           => 'puppetmaster.example.com',
          :puppetversion  => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        confdir = '/etc/puppet'
        additional_facts = {}
      else
        confdir = '/etc/puppetlabs/puppet'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      if os_facts[:osfamily] == 'FreeBSD'
        confdir = '/usr/local/etc/puppet'
      end

      let :facts do
        default_facts.merge(additional_facts)
      end

      describe 'with no custom parameters' do
        let :pre_condition do
          "class {'puppet': agent => true}"
        end

        it do
          should contain_class('puppet::agent::service::daemon').with(:enabled => true)
          should contain_class('puppet::agent::service::cron').with(:enabled => false)
        end
        case os_facts[:kernel]
        when 'Linux'
          it do
            should contain_class('puppet::agent::service::systemd').with(:enabled => false)
            should contain_service('puppet-run.timer').with(:ensure => :stopped)
          end
        else
          it do
            should contain_class('puppet::agent::service::systemd').with(:enabled => false)
            should_not contain_service('puppet-run.timer')
          end
        end
      end

      describe 'when runmode => cron' do
        let :pre_condition do
          "class {'puppet': agent => true, runmode => 'cron'}"
        end
        it do
          should contain_class('puppet::agent::service::daemon').with(:enabled => false)
          should contain_class('puppet::agent::service::cron').with(:enabled => true)
        end
        case os_facts[:kernel]
        when 'Linux'
          it do
            should contain_class('puppet::agent::service::systemd').with(:enabled => false)
            should contain_service('puppet-run.timer').with(:ensure => :stopped)
          end
        else
          it do
            should contain_class('puppet::agent::service::systemd').with(:enabled => false)
            should_not contain_service('puppet-run.timer')
          end
        end
      end

      describe 'when runmode => systemd.timer' do
        let :pre_condition do
          "class {'puppet': agent => true, runmode => 'systemd.timer'}"
        end
        case os_facts[:kernel]
        when 'Linux'
          it do
            should contain_class('puppet::agent::service::daemon').with(:enabled => false)
            should contain_class('puppet::agent::service::cron').with(:enabled => false)
            should contain_class('puppet::agent::service::systemd').with(:enabled => true)
            should contain_service('puppet-run.timer').with(:ensure => :running)
          end
        else
          it { should raise_error(Puppet::Error, /Runmode of systemd.timer not supported on #{os_facts[:kernel]} operating systems!/) }
        end
      end

      describe 'when unavailable_runmodes => ["cron"]' do
        let :pre_condition do
          "class {'puppet': agent => true, unavailable_runmodes => ['cron']}"
        end

        it do
          should_not contain_cron('puppet')
        end
      end

      describe 'when runmode => none' do
        let :pre_condition do
          "class {'puppet': agent => true, runmode => 'none'}"
        end

        it do
          should contain_class('puppet::agent::service::daemon').with(:enabled => false)
          should contain_class('puppet::agent::service::cron').with(:enabled => false)
        end
        case os_facts[:kernel]
        when 'Linux'
          it do
            should contain_class('puppet::agent::service::systemd').with(:enabled => false)
            should contain_service('puppet-run.timer').with(:ensure => :stopped)
          end
        else
          it do
            should contain_class('puppet::agent::service::systemd').with(:enabled => false)
            should_not contain_service('puppet-run.timer')
          end
        end
      end

      describe 'when runmode => foo' do
        let :pre_condition do
          "class {'puppet': agent => true, runmode => 'foo'}"
        end

        it { should raise_error(Puppet::Error, /Runmode of foo not supported by puppet::agent::config!/) }
      end
    end
  end
end
