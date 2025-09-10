require 'spec_helper'

describe 'puppet' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      case facts[:os]['family']
      when 'FreeBSD'
        puppet_major = facts[:puppetversion].to_i

        bindir = '/usr/local/bin'
        client_package = "puppet#{puppet_major}"
        confdir = '/usr/local/etc/puppet'
        package_provider = nil
      when 'windows'
        bindir = 'C:/ProgramData/PuppetLabs/puppet/bin'
        client_package = 'puppet-agent'
        confdir = 'C:/ProgramData/PuppetLabs/puppet/etc'
        package_provider = 'chocolatey'
      when 'Archlinux'
        bindir = '/usr/bin'
        client_package = 'puppet'
        confdir = '/etc/puppetlabs/puppet'
        package_provider = nil
      else
        bindir = '/opt/puppetlabs/bin'
        client_package = 'puppet-agent'
        confdir = '/etc/puppetlabs/puppet'
        package_provider = nil
      end

      let(:facts) do
        # Cron/systemd timers are based on the IP - make it consistent
        override_facts(facts, networking: {ip: '192.0.2.100'})
      end

      let :params do
        {
          agent: true
        }
      end

      describe 'with no custom parameters' do
        # For windows we specify a package provider which doesn't compile
        if facts[:os]['family'] != 'windows'
          it { is_expected.to compile.with_all_deps }
        end

        # install
        it do
          is_expected.to contain_class('puppet::agent::install')
            .with_manage_packages(true)
            .with_package_name([client_package])
            .with_package_version('present')
            .with_package_provider(package_provider)
            .with_package_source(nil)
            .that_notifies(['Class[puppet::agent::config]', 'Class[puppet::agent::service]'])
        end

        it do
          is_expected.to contain_package(client_package)
            .with_ensure('present')
            .with_provider(package_provider)
            .with_source(nil)
            .with_install_options(nil)
        end

        # config
        it { is_expected.to contain_class('puppet::agent::config').that_notifies('Class[puppet::agent::service]') }
        it { is_expected.to contain_file(confdir).with_ensure('directory') }
        it { is_expected.to contain_concat("#{confdir}/puppet.conf") }
        it { is_expected.to contain_concat__fragment('puppet.conf_agent').with_content(/^\[agent\]/) }
        it { is_expected.to contain_puppet__config__agent('report').with_value('true') }
        it { is_expected.not_to contain_puppet__config__agent('prerun_command') }
        it { is_expected.not_to contain_puppet__config__agent('postrun_command') }

        # service
        it { is_expected.to contain_class('puppet::agent::service') }

        it { is_expected.to contain_class('puppet::agent::service::daemon').with_enabled(true) }
        it do
          is_expected.to contain_service('puppet')
            .with_ensure('running')
            .with_name('puppet')
            .with_hasstatus('true')
            .with_enable('true')
        end

        it { is_expected.to contain_class('puppet::agent::service::cron').with_enabled(false) }
        if os =~ /\A(windows|archlinux)/
          it { is_expected.not_to contain_cron('puppet') }
        else
          it { is_expected.to contain_cron('puppet').with_ensure('absent') }
        end

        it { is_expected.to contain_class('puppet::agent::service::systemd').with_enabled(false) }
        case os
        when /\A(debian|redhat|centos|scientific|fedora|ubuntu|sles|archlinux|oraclelinux|almalinux|rocky)-/
          it do
            is_expected.to contain_service('puppet-run.timer')
              .with_ensure(false)
              .with_provider('systemd')
              .with_name('puppet-run.timer')
              .with_enable(false)
          end

          it { is_expected.to contain_file('/etc/systemd/system/puppet-run.timer').with_ensure(:absent) }
          it { is_expected.to contain_file('/etc/systemd/system/puppet-run.service').with_ensure(:absent) }
        else
          it { is_expected.not_to contain_service('puppet-run.timer') }
          it { is_expected.not_to contain_file('/etc/systemd/system/puppet-run.timer') }
          it { is_expected.not_to contain_file('/etc/systemd/system/puppet-run.service') }
        end
      end

      describe 'set prerun_command will be included in config' do
        let :params do
          super().merge(prerun_command: '/my/prerun')
        end

        it { is_expected.to contain_puppet__config__agent('prerun_command').with_value('/my/prerun') }
      end

      describe 'set postrun_command will be included in config' do
        let :params do
          super().merge(postrun_command: '/my/postrun')
        end

        it { is_expected.to contain_puppet__config__agent('postrun_command').with_value('/my/postrun') }
      end

      describe 'with additional settings' do
        let :params do
          super().merge(agent_additional_settings: { 'ignoreschedules' => true })
        end

        it { is_expected.to contain_puppet__config__agent('ignoreschedules').with_value('true') }
      end

      context 'manage_packages' do
        describe 'when manage_packages => false' do
          let :params do
            super().merge(manage_packages: false)
          end

          it { is_expected.not_to contain_package(client_package) }
        end

        describe "when manage_packages => 'agent'" do
          let :params do
            super().merge(manage_packages: 'agent')
          end

          it { is_expected.to contain_package(client_package) }
        end

        describe "when manage_packages => 'server'" do
          let :params do
            super().merge(manage_packages: 'server')
          end

          it { is_expected.not_to contain_package(client_package) }
        end
      end

      context 'runmode' do
        describe 'when runmode => cron' do
          let :params do
            super().merge(runmode: 'cron')
          end

          case os
          when /\A(windows|archlinux)/
            it { is_expected.to raise_error(Puppet::Error, /Runmode of cron not supported on #{facts[:kernel]} operating systems!/) }
          when /\A(debian|redhat|centos|scientific|fedora|ubuntu|sles|oraclelinux|almalinux|rocky)-/
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_concat__fragment('puppet.conf_agent') }
            it { is_expected.to contain_class('puppet::agent::service::cron').with_enabled(true) }
            it { is_expected.to contain_class('puppet::agent::service::daemon').with_enabled(false) }
            it do
              is_expected.to contain_service('puppet')
                .with_ensure('stopped')
                .with_name('puppet')
                .with_hasstatus('true')
                .with_enable('false')
            end
            it { is_expected.to contain_class('puppet::agent::service::systemd').with_enabled(false) }
            it { is_expected.to contain_service('puppet-run.timer').with_ensure(false) }
            it do
              is_expected.to contain_cron('puppet')
                .with_command("#{bindir}/puppet agent --config #{confdir}/puppet.conf --onetime --no-daemonize")
                .with_user('root')
                .with_minute(%w[10 40])
                .with_hour('*')
            end
          else
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('puppet::agent::service::cron').with_enabled(true) }
            it { is_expected.to contain_class('puppet::agent::service::daemon').with_enabled(false) }
            it { is_expected.to contain_class('puppet::agent::service::systemd').with_enabled(false) }
            it { is_expected.not_to contain_service('puppet-run.timer') }
            it do
              is_expected.to contain_cron('puppet')
                .with_command("#{bindir}/puppet agent --config #{confdir}/puppet.conf --onetime --no-daemonize")
                .with_user('root')
                .with_minute(%w[10 40])
                .with_hour('*')
            end
          end
        end

        describe 'when runmode => cron with specified time' do
          let :params do
            super().merge(runmode: 'cron',
                          run_hour: 22,
                          run_minute: 01
                         )
          end

          case os
          when /\A(windows|archlinux)/
            it { is_expected.to raise_error(Puppet::Error, /Runmode of cron not supported on #{facts[:kernel]} operating systems!/) }
          when /\A(debian|redhat|centos|scientific|fedora|ubuntu|sles|oraclelinux|almalinux|rocky)-/
            it { is_expected.to contain_class('puppet::agent::service::cron').with_enabled(true) }
            it { is_expected.to contain_class('puppet::agent::service::daemon').with_enabled(false) }
            it do
              is_expected.to contain_service('puppet')
                .with_ensure('stopped')
                .with_name('puppet')
                .with_hasstatus('true')
                .with_enable('false')
            end
            it { is_expected.to contain_class('puppet::agent::service::systemd').with_enabled(false) }
            it { is_expected.to contain_service('puppet-run.timer').with_ensure(false) }
            it do
              is_expected.to contain_cron('puppet')
                .with_command("#{bindir}/puppet agent --config #{confdir}/puppet.conf --onetime --no-daemonize")
                .with_user('root')
                .with_minute('1')
                .with_hour('22')
            end
          else
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('puppet::agent::service::cron').with_enabled(true) }
            it { is_expected.to contain_class('puppet::agent::service::daemon').with_enabled(false) }
            it { is_expected.to contain_class('puppet::agent::service::systemd').with_enabled(false) }
            it { is_expected.not_to contain_service('puppet-run.timer') }
            it do
              is_expected.to contain_cron('puppet')
                .with_command("#{bindir}/puppet agent --config #{confdir}/puppet.conf --onetime --no-daemonize")
                .with_user('root')
                .with_minute('1')
                .with_hour('22')
            end
          end
        end

        describe 'when runmode => systemd.timer' do
          let :params do
            super().merge(runmode: 'systemd.timer')
          end

          case os
          when /\A(debian|redhat|centos|scientific|fedora|ubuntu|sles|archlinux|oraclelinux|almalinux|rocky)-/
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('puppet::agent::service::daemon').with_enabled(false) }
            it { is_expected.to contain_class('puppet::agent::service::cron').with_enabled(false) }
            it { is_expected.to contain_class('puppet::agent::service::systemd').with_enabled(true) }
            it { is_expected.to contain_service('puppet-run.timer').with_ensure(true) }

            it do
              is_expected.to contain_file('/etc/systemd/system/puppet-run.timer')
                .with_content(/.*OnCalendar\=\*-\*-\* \*\:10,40:00.*/)
            end

            it do
              is_expected.to contain_file('/etc/systemd/system/puppet-run.timer')
                .with_content(/^RandomizedDelaySec\=0$/)
            end

            it do
              is_expected.to contain_file('/etc/systemd/system/puppet-run.service')
                .with_content(%r{^ExecStart=#{bindir}/puppet agent --config #{confdir}/puppet.conf --onetime --no-daemonize --detailed-exitcode --no-usecacheonfailure$})
            end

            it do
              is_expected.to contain_service('puppet-run.timer')
                .with_provider('systemd')
                .with_ensure(true)
                .with_name('puppet-run.timer')
                .with_enable(true)
            end
          else
            it { is_expected.to raise_error(Puppet::Error, /Runmode of systemd.timer not supported on #{facts[:kernel]} operating systems!/) }
          end
        end

        describe 'when runmode => systemd.timer with configured time' do
          let :params do
            super().merge(runmode: 'systemd.timer',
                          run_hour: 22,
                          run_minute: 01
                         )
          end

          case os
          when /\A(debian|redhat|centos|scientific|fedora|ubuntu|sles|archlinux|oraclelinux|almalinux|rocky)-/
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('puppet::agent::service::daemon').with_enabled(false) }
            it { is_expected.to contain_class('puppet::agent::service::cron').with_enabled(false) }
            it { is_expected.to contain_class('puppet::agent::service::systemd').with_enabled(true) }
            it { is_expected.to contain_service('puppet-run.timer').with_ensure(true) }

            it do
              is_expected.to contain_file('/etc/systemd/system/puppet-run.timer')
                .with_content(/.*OnCalendar\=\*-\*-\* 22:1:00.*/)
            end

            it do
              is_expected.to contain_file('/etc/systemd/system/puppet-run.timer')
                .with_content(/^RandomizedDelaySec\=0$/)
            end

            it do
              is_expected.to contain_file('/etc/systemd/system/puppet-run.service')
                .with_content(%r{^ExecStart=#{bindir}/puppet agent --config #{confdir}/puppet.conf --onetime --no-daemonize --detailed-exitcode --no-usecacheonfailure$})
            end

            it do
              is_expected.to contain_service('puppet-run.timer')
                .with_provider('systemd')
                .with_ensure(true)
                .with_name('puppet-run.timer')
                .with_enable(true)
            end
          else
            it { is_expected.to raise_error(Puppet::Error, /Runmode of systemd.timer not supported on #{facts[:kernel]} operating systems!/) }
          end
        end

        describe 'when runmode => none' do
          let :params do
            super().merge(runmode: 'none')
          end

          # For windows we specify a package provider which doesn't compile
          if facts[:os]['family'] != 'windows'
            it { is_expected.to compile.with_all_deps }
          end
          it { is_expected.to contain_class('puppet::agent::service::daemon').with_enabled(false) }
          it { is_expected.to contain_class('puppet::agent::service::cron').with_enabled(false) }
          it { is_expected.to contain_class('puppet::agent::service::systemd').with_enabled(false) }

          case os
          when /\A(debian|redhat|centos|scientific|fedora|ubuntu|sles|archlinux|oraclelinux|almalinux|rocky)-/
            it { is_expected.to contain_service('puppet-run.timer').with_ensure(false) }
          else
            it { is_expected.not_to contain_service('puppet-run.timer') }
          end
        end

        describe 'when runmode => unmanaged' do
          let :params do
            super().merge(runmode: 'unmanaged')
          end

          # For windows we specify a package provider which doesn't compile
          if facts[:os]['family'] != 'windows'
            it { is_expected.to compile.with_all_deps }
          end
          it { is_expected.to contain_class('puppet::agent::service::daemon').with_enabled(false) }
          it { is_expected.to contain_class('puppet::agent::service::cron').with_enabled(false) }
          it { is_expected.to contain_class('puppet::agent::service::systemd').with_enabled(false) }
          it { is_expected.not_to contain_cron('puppet') }
          it { is_expected.not_to contain_service('puppet') }
          it { is_expected.not_to contain_service('puppet-run.timer') }
        end
      end

      describe 'when unavailable_runmodes => ["cron"]' do
        let :params do
          super().merge(unavailable_runmodes: ['cron'])
        end

        it { is_expected.not_to contain_cron('puppet') }
      end

      describe 'with custom service_name' do
        let :params do
          super().merge(service_name: 'pe-puppet')
        end

        it { is_expected.to contain_service('puppet').with_name('pe-puppet') }
      end

      context 'with report => false' do
        let :params do
          super().merge(report: false)
        end

        it { is_expected.to contain_puppet__config__agent('report').with_value('false') }
      end

      context 'with agent_manage_environment false' do
        let(:params) { { agent_manage_environment: false } }

        it do
          is_expected.not_to contain_puppet__config__agent('environment')
        end
      end
    end
  end
end
