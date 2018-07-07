require 'spec_helper'

describe 'puppet::agent::service::systemd' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      if facts[:osfamily] == 'FreeBSD'
        bindir = '/usr/local/bin'
        confdir = '/usr/local/etc/puppet'
      elsif facts[:osfamily] == 'Archlinux'
        bindir = '/usr/bin'
        confdir = '/etc/puppetlabs/puppet'
      else
        bindir = '/opt/puppetlabs/bin'
        confdir = '/etc/puppetlabs/puppet'
      end

      let :facts do
        facts.merge(ipaddress: '192.0.2.100')
      end

      describe 'when runmode is not systemd' do
        let :pre_condition do
          "class {'puppet': agent => true}"
        end

        case os
        when /\Adebian-(8|9)/, /\A(redhat|centos|scientific)-7/, /\Afedora-/, /\Aubuntu-(16|18)/, /\Aarchlinux-/
          it 'should disable systemd timer' do
            should contain_class('puppet::agent::service::systemd').with({
              'enabled' => false,
            })

            should contain_service('puppet-run.timer').with({
              :provider => 'systemd',
              :ensure   => 'stopped',
              :name     => 'puppet-run.timer',
              :enable   => 'false',
            })

            should contain_file('/etc/systemd/system/puppet-run.timer').with_ensure(:absent)
            should contain_file('/etc/systemd/system/puppet-run.service').with_ensure(:absent)

            should contain_exec('systemctl-daemon-reload-puppet').with({
              :refreshonly => true,
              :command     => 'systemctl daemon-reload',
            })
          end
        else
          it 'should not have a systemd timer service' do
            should_not contain_service('puppet-run.timer')
            should_not contain_file('/etc/systemd/system/puppet-run.timer')
            should_not contain_file('/etc/systemd/system/puppet-run.service')
            should_not contain_exec('systemctl-daemon-reload-puppet')
          end
        end
      end

      describe 'when runmode => systemd.timer' do
        let :pre_condition do
          "class {'puppet': agent => true, runmode => 'systemd.timer'}"
        end

        case os
        when /\Adebian-(8|9)/, /\A(redhat|centos|scientific)-7/, /\Afedora-/, /\Aubuntu-(16|18)/, /\Aarchlinux-/
          it 'should enable systemd timer' do
            should contain_class('puppet::agent::service::systemd').with_enabled(true)

            should contain_file('/etc/systemd/system/puppet-run.timer').
              with_content(/.*OnCalendar\=\*-\*-\* \*\:10,40:00.*/)

            should contain_file('/etc/systemd/system/puppet-run.timer').
              with_content(/^RandomizedDelaySec\=0$/)

            should contain_file('/etc/systemd/system/puppet-run.service').
              with_content(/.*ExecStart=#{bindir}\/puppet agent --config #{confdir}\/puppet.conf --onetime --no-daemonize.*/)

            should contain_exec('systemctl-daemon-reload-puppet').with({
              :refreshonly => true,
              :command     => 'systemctl daemon-reload',
            })

            should contain_service('puppet-run.timer').with({
              :provider => 'systemd',
              :ensure   => 'running',
              :name     => 'puppet-run.timer',
              :enable   => 'true',
            })
          end
        else
          it { should raise_error(Puppet::Error, /Runmode of systemd.timer not supported on #{facts[:kernel]} operating systems!/) }
        end
      end
    end
  end
end
