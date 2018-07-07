require 'spec_helper'

describe 'puppet::agent::service' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      if facts[:osfamily] == 'FreeBSD'
        confdir = '/usr/local/etc/puppet'
      else
        confdir = '/etc/puppetlabs/puppet'
      end

      let :facts do
        facts
      end

      describe 'with no custom parameters' do
        let :pre_condition do
          "class {'puppet': agent => true}"
        end

        it do
          should contain_class('puppet::agent::service::daemon').with(:enabled => true)
          should contain_class('puppet::agent::service::cron').with(:enabled => false)
        end
        case os
        when /\Adebian-(8|9)/, /\A(redhat|centos|scientific)-7/, /\Afedora-/, /\Aubuntu-(16|18)/, /\Aarchlinux-/
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
        case os
        when /\A(windows|archlinux)/
          it do
            should raise_error(Puppet::Error, /Runmode of cron not supported on #{facts[:kernel]} operating systems!/)
          end
        when /\Adebian-(8|9)/, /\A(redhat|centos|scientific)-7/, /\Afedora-/, /\Aubuntu-(16|18)/
          it do
            should contain_class('puppet::agent::service::cron').with(:enabled => true)
            should contain_class('puppet::agent::service::daemon').with(:enabled => false)
            should contain_class('puppet::agent::service::systemd').with(:enabled => false)
            should contain_service('puppet-run.timer').with(:ensure => :stopped)
          end
        else
          it do
            should contain_class('puppet::agent::service::cron').with(:enabled => true)
            should contain_class('puppet::agent::service::daemon').with(:enabled => false)
            should contain_class('puppet::agent::service::systemd').with(:enabled => false)
            should_not contain_service('puppet-run.timer')
          end
        end
      end

      describe 'when runmode => systemd.timer' do
        let :pre_condition do
          "class {'puppet': agent => true, runmode => 'systemd.timer'}"
        end
        case os
        when /\Adebian-(8|9)/, /\A(redhat|centos|scientific)-7/, /\Afedora-/, /\Aubuntu-(16|18)/, /\Aarchlinux-/
          it do
            should contain_class('puppet::agent::service::daemon').with(:enabled => false)
            should contain_class('puppet::agent::service::cron').with(:enabled => false)
            should contain_class('puppet::agent::service::systemd').with(:enabled => true)
            should contain_service('puppet-run.timer').with(:ensure => :running)
          end
        else
          it { should raise_error(Puppet::Error, /Runmode of systemd.timer not supported on #{facts[:kernel]} operating systems!/) }
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
        case os
        when /\Adebian-(8|9)/, /\A(redhat|centos|scientific)-7/, /\Afedora-/, /\Aubuntu-(16|18)/, /\Aarchlinux-/
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
    end
  end
end
