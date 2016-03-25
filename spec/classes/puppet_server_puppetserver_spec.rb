require 'spec_helper'

describe 'puppet::server::puppetserver' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    next if os_facts[:osfamily] == 'windows'
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :puppetversion  => Puppet.version,
          :ipaddress      => '192.0.2.10',
          :processorcount => 1,
      }) end

      let :pre_condition do
        "class {'puppet': server_implementation => 'puppetserver'}"
      end

      if Puppet.version < '4.0'
        additional_facts = {}
      else
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      let(:facts) { default_facts.merge(additional_facts) }

      let(:default_params) do {
        :java_bin                    => '/usr/bin/java',
        :config                      => '/etc/default/puppetserver',
        :jvm_min_heap_size           => '2G',
        :jvm_max_heap_size           => '2G',
        :jvm_extra_args              => '',
        :server_ca_client_whitelist  => [ '127.0.0.1', '::1', '192.0.2.10', ],
        :server_admin_api_whitelist  => [ '127.0.0.1', '::1', '192.0.2.10', ],
        :server_ruby_load_paths      => [ '/some/path', ],
        :server_ssl_protocols        => [ 'TLSv1.2', ],
        :server_cipher_suites        => [ 'TLS_RSA_WITH_AES_256_CBC_SHA256',
                                          'TLS_RSA_WITH_AES_256_CBC_SHA',
                                          'TLS_RSA_WITH_AES_128_CBC_SHA256',
                                          'TLS_RSA_WITH_AES_128_CBC_SHA', ],
        :server_max_active_instances => 2,
        :server_ca                   => true,
        :server_puppetserver_version => '2.3.1',
        :server_use_legacy_auth_conf => false,
      } end

      describe 'with default parameters' do
        let(:params) do
          default_params.merge({
            :server_puppetserver_dir => '/etc/custom/puppetserver',
          })
        end
        it {
          should contain_file_line('ca_enabled').
            with_ensure('present').
            with_line('puppetlabs.services.ca.certificate-authority-service/certificate-authority-service')
        }
        it {
          should contain_file_line('ca_disabled').
            with_ensure('absent').
            with_line('puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service')
        }
        it { should contain_augeas('puppet::server::puppetserver::jvm').
                with_changes([
                  'set JAVA_ARGS \'"-Xms2G -Xmx2G"\'',
                  'set JAVA_BIN /usr/bin/java',
                ]).
                with_context('/files/etc/default/puppetserver').
                with_incl('/etc/default/puppetserver').
                with_lens('Shellvars.lns').
                with({})
        }
        it { should contain_file('/etc/custom/puppetserver/conf.d/ca.conf') }
        it { should contain_file('/etc/custom/puppetserver/conf.d/puppetserver.conf') }
        it { should contain_file('/etc/custom/puppetserver/conf.d/web-routes.conf') }
        it { should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
                                 with_content(/ssl-host\s+=\s0\.0\.0\.0/) }
        it { should contain_file('/etc/custom/puppetserver/conf.d/auth.conf') }
      end

      describe 'use-legacy-auth-conf' do
        context 'with default parameters' do
          let(:params) do
            default_params.merge({
              :server_puppetserver_dir => '/etc/custom/puppetserver',
            })
          end
          it 'should have use-legacy-auth-conf: false in puppetserver.conf' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    use-legacy-auth-conf: false\n])
          end
        end
        context 'when use-legacy-auth-conf = true' do
          let(:params) do
            default_params.merge({
              :server_use_legacy_auth_conf => true,
              :server_puppetserver_dir     => '/etc/custom/puppetserver',
            })
          end
          it 'should have use-legacy-auth-conf: true in puppetserver.conf' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    use-legacy-auth-conf: true\n])
          end
        end
        context 'when server_puppetserver_version < 2.2' do
          let(:params) do
            default_params.merge({
              :server_puppetserver_version => '2.1.2',
              :server_puppetserver_dir     => '/etc/custom/puppetserver',
            })
          end
          it 'should not have a use-legacy-auth-conf setting in puppetserver.conf' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).not_to include('use-legacy-auth-conf')
          end
        end
      end

      describe 'versioned-code-service' do
        context 'when server_puppetserver_version >= 2.3' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it 'should have versioned-code-service in bootstrap.cfg' do
            should contain_file_line('versioned_code_service').
                with_ensure('present').
                with_line('puppetlabs.services.versioned-code-service.versioned-code-service/versioned-code-service')
          end
        end

        context 'when server_puppetserver_version < 2.3' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.2.2',
                                     :server_puppetserver_dir     => '/etc/custom/puppetserver',
                                 })
          end
          it 'should not have versioned-code-service in bootstrap.cfg' do
            should contain_file_line('versioned_code_service').
                with_ensure('absent').
                with_line('puppetlabs.services.versioned-code-service.versioned-code-service/versioned-code-service')
          end
        end
      end

      describe 'with extra_args parameter' do
        let :params do
          default_params.merge({
            :jvm_extra_args => ['-XX:foo=bar', '-XX:bar=foo'],
          })
        end

        it { should contain_augeas('puppet::server::puppetserver::jvm').
                with_changes([
                  'set JAVA_ARGS \'"-Xms2G -Xmx2G -XX:foo=bar -XX:bar=foo"\'',
                  'set JAVA_BIN /usr/bin/java',
                ]).
                with_context('/files/etc/default/puppetserver').
                with_incl('/etc/default/puppetserver').
                with_lens('Shellvars.lns').
                with({})
        }
      end

      describe 'with jvm_config file parameter' do
        let :params do default_params.merge({
            :config => '/etc/custom/puppetserver',
          })
        end
        it { should contain_augeas('puppet::server::puppetserver::jvm').
                with_context('/files/etc/custom/puppetserver').
                with_incl('/etc/custom/puppetserver').
                with_lens('Shellvars.lns').
                with({})
        }
      end

      describe 'with server_ip parameter given to the puppet class' do
        let(:params) do
          default_params.merge({
            :server_puppetserver_dir => '/etc/custom/puppetserver',
          })
        end

        let :pre_condition do
          "class {'puppet': server_ip => '127.0.0.1', server_implementation => 'puppetserver'}"
        end

        it 'should put the correct ip address in webserver.conf' do
          should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').with_content(/ssl-host\s+=\s127\.0\.0\.1/)
        end
      end

      describe 'with server_certname parameter given to the puppet class' do
        let(:params) do
          default_params.merge({
            :server_puppetserver_dir => '/etc/custom/puppetserver',
          })
        end

        let :pre_condition do
          "class {'puppet': server_certname => 'puppetserver43.example.com', server_implementation => 'puppetserver', server_ssl_dir => '/etc/custom/puppet/ssl'}"
        end

        it 'should put the correct ssl key path in webserver.conf' do
          should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
            with_content(/ssl-key\s+=\s\/etc\/custom\/puppet\/ssl\/private_keys\/puppetserver43\.example\.com\.pem/)
        end

        it 'should put the correct ssl cert path in webserver.conf' do
          should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
            with_content(/ssl-cert\s+=\s\/etc\/custom\/puppet\/ssl\/certs\/puppetserver43\.example\.com\.pem/)
        end
      end
    end
  end
end
