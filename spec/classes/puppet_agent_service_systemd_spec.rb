require 'spec_helper'

describe 'puppet::agent::service::systemd' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      if Puppet.version < '4.0'
        confdir = '/etc/puppet'
        additional_facts = {}
      else
        confdir = '/etc/puppetlabs/puppet'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      if facts[:osfamily] == 'FreeBSD'
        confdir = '/usr/local/etc/puppet'
      elsif facts[:osfamily] == 'Archlinux'
        confdir = '/etc/puppetlabs/puppet'
      end

      let :facts do
        facts.merge(additional_facts)
      end

      describe 'when runmode is not systemd' do
        let :pre_condition do
          "class {'puppet': agent => true}"
        end

        case os
        when /\Adebian-8/, /\A(redhat|centos|scientific)-7/, /\Afedora-/, /\Aubuntu-16/, /\Aarchlinux-/
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

        if Puppet.version < '4.0'
          bindir = '/usr/bin'
        elsif facts[:osfamily] == 'FreeBSD'
          bindir = '/usr/local/bin'
        elsif facts[:osfamily] == 'Archlinux'
          bindir = '/usr/bin'
        else
          bindir = '/opt/puppetlabs/bin'
        end

        case os
        when /\Adebian-8/, /\A(redhat|centos|scientific)-7/, /\Afedora-/, /\Aubuntu-16/, /\Aarchlinux-/
          it 'should enable systemd timer' do
            should contain_class('puppet::agent::service::systemd').with({
              'enabled' => true,
            })

            should contain_file('/etc/systemd/system/puppet-run.timer').
            with_content(/.*OnCalendar\=\*-\*-\* \*\:15,45:00.*/)

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
