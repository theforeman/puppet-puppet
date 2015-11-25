require 'spec_helper'

describe 'puppet::agent::service::systemd' do
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

      describe 'when runmode is not systemd' do
        let :pre_condition do
          "class {'puppet': agent => true}"
        end

        case os
        when /\Adebian-8/, /\A(redhat|centos|scientific)-7/, /\Afedora-/
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
        when /\Adebian-8/, /\A(redhat|centos|scientific)-7/, /\Afedora-/
          it 'should enable systemd timer' do
            should contain_class('puppet::agent::service::systemd').with({
              'enabled' => true,
            })

            should contain_file('/etc/systemd/system/puppet-run.timer').
            with_content(/.*OnCalendar\=\*-\*-\* \*\:15,45:00.*/)

            should contain_file('/etc/systemd/system/puppet-run.service').
            with_content(/.*ExecStart=\/usr\/bin\/env puppet agent --config #{confdir}\/puppet.conf --onetime --no-daemonize.*/)

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
          it { should raise_error(Puppet::Error, /Runmode of systemd.timer not supported on #{os_facts[:kernel]} operating systems!/) }
        end
      end
    end
  end
end
