require 'spec_helper'
require 'deep_merge'

describe 'puppet' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      case facts[:osfamily]
      when 'FreeBSD'
        dir_owner = 'puppet'
        dir_group = 'puppet'
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
        dir_owner = 'puppet'
        dir_group = 'puppet'
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
        facts.merge(domain: 'example.org')
      end

      let :params do
        {}
      end

      describe 'with default parameters' do
        it { is_expected.to contain_file(confdir).with_owner(dir_owner).with_group(dir_group) }
        it { is_expected.to contain_file("#{confdir}/auth.conf").with_content(%r{/puppet/v3/}) }
        it { is_expected.not_to contain_file("#{confdir}/auth.conf").with_content(%r{^path /certificate_revocation_list/ca\nmethod find$}) }
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
        it { is_expected.to contain_puppet__config__main('server').with_value(facts[:fqdn]) }
      end

      describe 'with allow_any_crl_auth' do
        let :params do
          super().merge(allow_any_crl_auth: true)
        end

        it { is_expected.to contain_file("#{confdir}/auth.conf").with_content(%r{^path /puppet-ca/v1/certificate_revocation_list/ca\nauth any$}) }
      end

      describe 'with auth_allowed' do
        let :params do
          super().merge(auth_allowed: ['$1', 'puppetproxy'])
        end

        it { is_expected.to contain_file("#{confdir}/auth.conf").with_content(/^allow \$1, puppetproxy$/) }
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
          let(:facts) { facts.merge(domain: nil) }

          it { is_expected.to raise_error(Puppet::Error, /\$::domain fact found to be undefined and \$srv_domain is undefined/) }
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
        context 'with client_certname => $::clientcert' do
          let :facts do
            # rspec-puppet(-facts) doesn't mock this
            facts.deep_merge(clientcert: 'client.example.com')
          end
          let :params do
            super().merge(client_certname: facts[:clientcert])
          end

          it { is_expected.to contain_puppet__config__main('certname').with_value(facts[:clientcert]) }
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

      context 'puppetmaster' do
        describe "when puppetmaster => 'mymaster.example.com'" do
          let :params do
            super().merge(puppetmaster: 'mymaster.example.com')
          end

          it { is_expected.to contain_puppet__config__main('server').with_value('mymaster.example.com') }
        end

        describe 'puppetmaster parameter overrides global puppetmaster' do
          let :params do
            super().merge(puppetmaster: 'mymaster.example.com')
          end

          let :facts do
            facts.merge(puppetmaster: 'global.example.com')
          end

          it { is_expected.to contain_puppet__config__main('server').with_value('mymaster.example.com') }
        end

        describe 'global puppetmaster overrides fqdn' do
          let :facts do
            facts.merge(puppetmaster: 'global.example.com')
          end

          it { is_expected.to contain_puppet__config__main('server').with_value('global.example.com') }
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
