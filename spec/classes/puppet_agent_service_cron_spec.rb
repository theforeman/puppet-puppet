require 'spec_helper'
require 'deep_merge'

describe 'puppet::agent::service::cron' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      if facts[:osfamily] == 'FreeBSD'
        bindir = '/usr/local/bin'
        confdir = '/usr/local/etc/puppet'
      else
        confdir = '/etc/puppetlabs/puppet'
        bindir = '/opt/puppetlabs/bin'
      end

      let :facts do
        facts.deep_merge(networking: { ip: '192.0.2.100' })
      end

      describe 'when runmode is not cron' do
        let :pre_condition do
          "class {'puppet': agent => true}"
        end

        if os =~ /\A(windows|archlinux)/
          it { should_not contain_cron('puppet') }
        else
          it { should contain_cron('puppet').with_ensure('absent') }
        end
      end

      describe 'when runmode => cron' do
        let :pre_condition do
          "class {'puppet': agent => true, runmode => 'cron'}"
        end

        it do
          case os
          when /\A(windows|archlinux)/
            should raise_error(Puppet::Error, /Runmode of cron not supported on #{facts[:kernel]} operating systems!/)
          else
            should contain_cron('puppet').with({
              :command  => "#{bindir}/puppet agent --config #{confdir}/puppet.conf --onetime --no-daemonize",
              :user     => 'root',
              :minute   => ['10','40'],
              :hour     => '*',
            })
          end
        end
      end
    end
  end
end
