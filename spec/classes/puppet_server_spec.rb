require 'spec_helper'

describe 'puppet::server' do
  on_os_under_test.each do |os, facts|
    next if unsupported_puppetmaster_osfamily(facts[:osfamily])
    context "on #{os}" do
      if facts[:osfamily] == 'FreeBSD'
        ssldir = '/var/puppet/ssl'
      else
        ssldir = '/var/lib/puppet/ssl'
      end

      server_package = 'puppet-server'
      if facts[:osfamily] == 'Debian'
        server_package = 'puppetmaster'
        if facts[:puppetversion].to_f > 4.0
          server_package = 'puppet-master'
        end
      end

      let(:facts) { facts }

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
              with_httpd_service('httpd').
              with_puppetmaster(false).
              with_puppetserver(nil).
              with_rack(true)
          end
          it { should contain_user('puppet') }
          it { should_not contain_notify('ip_not_supported') }
          # No server_package for FreeBSD
          unless facts[:osfamily] == 'FreeBSD'
            it { should contain_package(server_package) }
          end
          if facts[:osfamily] == 'Debian'
            it do
              should contain_file('/etc/default/puppetmaster').
                with_content("START=no\n").
                that_comes_before("Package[#{server_package}]")
            end
          end
        end
      end

      describe 'with uppercase hostname' do
        let :pre_condition do
          "class {'puppet': server => true}"
        end

        let(:facts) do
          facts.merge(
            :fqdn       => 'PUPPETMASTER.example.com',
            # clientcert is always lowercase by Puppet design
            :clientcert => 'puppetmaster.example.com',
          )
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

      describe 'with ip parameter' do
        describe 'with default server implementation' do
          let :pre_condition do
            "class {'puppet': server_ip => '127.0.0.1'}"
          end

          it 'should issue a warning because server_ip is not supported by default implementation' do
            should contain_notify('ip_not_supported').
              with_message('Bind IP address is unsupported for the master implementation.').
              with_loglevel('warning')
          end
        end

        describe 'with server_implementation => "puppetserver"' do
          let :pre_condition do
            "class {'puppet': server_ip => '127.0.0.1', server_implementation => 'puppetserver'}"
          end

          it { should_not contain_notify('ip_not_supported') }
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
            with_puppetserver(nil).
            with_rack(false)
        end

        describe "and server_service_fallback => false" do
          let :pre_condition do
            "class {'puppet': server => true, server_passenger => false, server_service_fallback => false}"
          end

          it { should compile.with_all_deps }
          it do
            should contain_class('puppet::server::service').
              with_puppetmaster(false).
              with_puppetserver(nil).
              with_rack(false)
          end
        end
      end

      describe 'with server_implementation => "puppetserver"' do
        let :facts do
          facts.merge(:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0')
        end
        let :pre_condition do
          "class {'puppet': server => true, server_implementation => 'puppetserver'}"
        end
        it { should compile.with_all_deps }
        it { should_not contain_class('apache') }
        it { should_not contain_notify('ip_not_supported') }
        it do
          should contain_class('puppet::server::service').
            with_puppetmaster(nil).
            with_puppetserver(true).
            with_rack(false)
        end
        it { should contain_class('puppet::server::puppetserver') }
        it { should contain_package('puppetserver') }
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
        # Puppetmaster is not a separate package on FreeBSD
        unless facts[:osfamily] == 'FreeBSD'
          it { should contain_package(server_package) }
        end
      end
    end
  end
end
