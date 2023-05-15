require 'spec_helper'

describe 'puppet' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      case os_facts[:osfamily]
      when 'FreeBSD'
        dir_owner = 'root'
        dir_group = nil
        confdir   = '/usr/local/etc/puppet'
        logdir    = '/var/log/puppet'
        rundir    = '/var/run/puppet'
        ssldir    = '/var/puppet/ssl'
        vardir    = '/var/puppet'
      when 'windows'
        dir_owner = nil
        dir_group = nil
        confdir   = 'C:/ProgramData/PuppetLabs/puppet/etc'
        logdir    = 'C:/ProgramData/PuppetLabs/puppet/var/log'
        rundir    = 'C:/ProgramData/PuppetLabs/puppet/var/run'
        ssldir    = 'C:/ProgramData/PuppetLabs/puppet/etc/ssl'
        vardir    = 'C:/ProgramData/PuppetLabs/puppet/var'
      when 'Archlinux'
        dir_owner = 'root'
        dir_group = nil
        confdir   = '/etc/puppetlabs/puppet'
        logdir    = '/var/log/puppetlabs/puppet'
        rundir    = '/var/run/puppetlabs'
        ssldir    = '/etc/puppetlabs/puppet/ssl'
        vardir    = '/opt/puppetlabs/puppet/cache'
      else
        dir_owner = 'root'
        dir_group = nil
        confdir   = '/etc/puppetlabs/puppet'
        logdir    = '/var/log/puppetlabs/puppet'
        rundir    = '/var/run/puppetlabs'
        ssldir    = '/etc/puppetlabs/puppet/ssl'
        vardir    = '/opt/puppetlabs/puppet/cache'
      end

      let :facts do
        override_facts(os_facts, networking: {domain: 'example.org'})
      end

      let :params do
        {}
      end

      describe 'with default parameters' do
        it { is_expected.to contain_file(confdir).with_owner(dir_owner).with_group(dir_group) }
        it { is_expected.not_to contain_puppet__config__main('default_manifest') }
        it { is_expected.not_to contain_file('/etc/puppet/manifests/default_manifest.pp') }
        it { is_expected.not_to contain_puppet__config__main('reports') }
        it { is_expected.to contain_puppet__config__main('vardir').with_value(vardir) }
        it { is_expected.to contain_puppet__config__main('logdir').with_value(logdir) }
        it { is_expected.to contain_puppet__config__main('rundir').with_value(rundir) }
        it { is_expected.to contain_puppet__config__main('ssldir').with_value(ssldir) }
        it { is_expected.to contain_puppet__config__main('privatekeydir').with_value('$ssldir/private_keys { group = service }') }
        it { is_expected.to contain_puppet__config__main('hostprivkey').with_value('$privatekeydir/$certname.pem { mode = 640 }') }
        it { is_expected.to contain_puppet__config__main('show_diff').with_value('false') }
        it { is_expected.to contain_puppet__config__main('server').with_value(facts[:networking]['fqdn']) }
      end

      describe "when dns_alt_names => ['foo','bar']" do
        let :params do
          super().merge(dns_alt_names: %w[foo bar])
        end

        it { is_expected.to contain_puppet__config__main('dns_alt_names').with_value(%w[foo bar]) }
      end

      describe "when syslogfacility => 'local6'" do
        let :params do
          super().merge(syslogfacility: 'local6')
        end

        it { is_expected.to contain_puppet__config__main('syslogfacility').with_value('local6') }
      end

      describe "when module_repository => 'https://myforgeapi.example.com'" do
        let :params do
          super().merge(module_repository: 'https://myforgeapi.example.com')
        end

        it { is_expected.to contain_puppet__config__main('module_repository').with_value('https://myforgeapi.example.com') }
      end

      describe 'when use_srv_records => true' do
        let :params do
          super().merge(use_srv_records: true)
        end

        context 'domain fact is defined' do
          it { is_expected.to contain_puppet__config__main('use_srv_records').with_value('true') }
          it { is_expected.to contain_puppet__config__main('srv_domain').with_value('example.org') }
          it { is_expected.to contain_puppet__config__main('pluginsource').with_value('puppet:///plugins') }
          it { is_expected.to contain_puppet__config__main('pluginfactsource').with_value('puppet:///pluginfacts') }
          it { is_expected.not_to contain_puppet__config__main('server') }
        end

        context 'domain fact is unset' do
          let(:facts) { override_facts(super(), networking: {domain: nil}) }

          it { is_expected.to raise_error(Puppet::Error, /domain fact found to be undefined and \$srv_domain is undefined/) }
        end

        context 'is overriden via param' do
          let :params do
            super().merge(srv_domain: 'special.example.com')
          end

          it { is_expected.to contain_puppet__config__main('use_srv_records').with_value(true) }
          it { is_expected.to contain_puppet__config__main('srv_domain').with_value('special.example.com') }
        end
      end

      describe 'client_certname' do
        let(:node) { 'client.example.com' }

        context 'with client_certname => trusted certname' do
          it { is_expected.to contain_puppet__config__main('certname').with_value('client.example.com') }
        end

        context 'with client_certname => "foobar"' do
          let :params do
            super().merge(client_certname: 'foobar')
          end

          it { is_expected.to contain_puppet__config__main('certname').with_value('foobar') }
        end

        context 'with client_certname => false' do
          let :params do
            super().merge(client_certname: false)
          end

          it { is_expected.not_to contain_puppet__config__main('certname') }
        end
      end

      context 'agent_server_hostname' do
        describe "when agent_server_hostname => 'myserver.example.com'" do
          let :params do
            super().merge(agent_server_hostname: 'myserver.example.com')
          end

          it { is_expected.to contain_puppet__config__main('server').with_value('myserver.example.com') }
        end

        # puppetmaster is provided via the Foreman ENC as a global variable
        context 'with global puppetmaster' do
          let(:facts) { super().merge(puppetmaster: 'global.example.com') }

          describe 'it overrides fqdn' do
            it { is_expected.to contain_puppet__config__main('server').with_value('global.example.com') }
          end

          describe 'the agent_server_hostname parameter overrides global puppetmaster' do
            let(:params) { super().merge(agent_server_hostname: 'myserver.example.com') }

            it { is_expected.to contain_puppet__config__main('server').with_value('myserver.example.com') }
          end
        end
      end

      describe 'with additional settings' do
        let :params do
          super().merge(additional_settings: { disable_warnings: 'deprecations' })
        end

        it { is_expected.to contain_puppet__config__main('disable_warnings').with_value('deprecations') }
      end
    end
  end
end
