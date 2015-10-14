require 'spec_helper'

describe 'puppet::server' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :clientcert             => 'puppetmaster.example.com',
          :concat_basedir         => '/nonexistant',
          :fqdn                   => 'puppetmaster.example.com',
          :puppetversion          => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        ssldir           = '/var/lib/puppet/ssl'
        additional_facts = {}
      else
        ssldir           = '/etc/puppetlabs/puppet/ssl'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      if os_facts[:osfamily] == 'FreeBSD'
        ssldir = '/var/puppet/ssl'
      end

      server_package = 'puppet-server'
      if os_facts[:osfamily] == 'Debian'
        server_package = 'puppetmaster'
      end

      let(:facts) { default_facts.merge(additional_facts) }

      describe 'basic case' do
        let :pre_condition do
          "class {'puppet': server => true}"
        end

        describe 'with no custom parameters' do
          it { should compile.with_all_deps }
          it 'should include classes' do
            should contain_class('puppet::server::install')
            should contain_class('puppet::server::config')
            should contain_class('puppet::server::service').
              with_puppetmaster(false).
              with_puppetserver(nil)
          end
          # No server_package for FreeBSD
          if not os_facts[:osfamily] == 'FreeBSD'
            it { should contain_package(server_package) }
          end
        end
      end

      describe 'with uppercase hostname' do
        let :pre_condition do
          "class {'puppet': server => true}"
        end

        let(:facts) do
          super().merge({
            :clientcert => 'PUPPETMASTER.example.com',
            :fqdn       => 'PUPPETMASTER.example.com',
          })
        end

        describe 'with no custom parameters' do
          it 'should use lowercase certificates' do
            should contain_class('puppet::server::passenger').
              with_ssl_cert("#{ssldir}/certs/puppetmaster.example.com.pem").
              with_ssl_cert_key("#{ssldir}/private_keys/puppetmaster.example.com.pem").
              with_ssl_ca_crl("#{ssldir}/ca/ca_crl.pem")
          end
        end
      end

      describe 'with server_passenger => false' do
        let :pre_condition do
          "class {'puppet': server => true, server_passenger => false}"
        end

        it { should compile.with_all_deps }
        it { should_not contain_class('apache') }
        it do
          should contain_class('puppet::server::service').
            with_puppetmaster(true).
            with_puppetserver(nil)
        end

        describe "and server_service_fallback => false" do
          let :pre_condition do
            "class {'puppet': server => true, server_passenger => false, server_service_fallback => false}"
          end

          it { should compile.with_all_deps }
          it do
            should contain_class('puppet::server::service').
              with_puppetmaster(false).
              with_puppetserver(nil)
          end
        end
      end

      describe 'with server_implementation => "puppetserver"' do
        let :pre_condition do
          "class {'puppet': server => true, server_implementation => 'puppetserver'}"
        end

        it { should compile.with_all_deps }
        it { should_not contain_class('apache') }
        it do
          should contain_class('puppet::server::service').
            with_puppetmaster(nil).
            with_puppetserver(true)
        end
        it { should contain_class('puppet::server::puppetserver') }
        it { should contain_package('puppetserver') }
      end

      describe 'with unknown server_implementation' do
        let :pre_condition do
          "class {'puppet': server => true, server_implementation => 'golang'}"
        end
        it { should raise_error(Puppet::Error, /"golang" does not match/) }
      end

      describe "when manage_packages => false" do
        let :pre_condition do
          "class { 'puppet': server => true, manage_packages => false,
                             server_implementation => 'master' }"
        end

        it { should compile.with_all_deps }
        it "should not contain Package[#{server_package}]" do
          should_not contain_package(server_package)
        end
      end

      describe "when manage_packages => 'agent'" do
        let :pre_condition do
          "class { 'puppet': server => true, manage_packages => 'agent',
                             server_implementation => 'master' }"
        end

        it { should compile.with_all_deps }
        it "should not contain Package[#{server_package}]" do
          should_not contain_package(server_package)
        end
      end

      describe "when manage_packages => 'server'" do
        let :pre_condition do
          "class { 'puppet': server => true, manage_packages => 'server',
                             server_implementation => 'master' }"
        end

        it { should compile.with_all_deps }
        # Puppetmaster not supported on FreeBSD
        if not os_facts[:osfamily] == 'FreeBSD'
          it { should contain_package(server_package) }
        end
      end

    end
  end
end
