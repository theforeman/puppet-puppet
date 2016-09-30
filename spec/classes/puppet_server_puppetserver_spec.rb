require 'spec_helper'

describe 'puppet::server::puppetserver' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    next if os_facts[:osfamily] == 'windows'
    next if os_facts[:osfamily] == 'FreeBSD'
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
        :server_ca_auth_required     => true,
        :server_ca_client_whitelist  => [ 'localhost', 'puppetserver123.example.com' ],
        :server_admin_api_whitelist  => [ 'localhost', 'puppetserver123.example.com' ],
        :server_ruby_load_paths      => [ '/some/path', ],
        :server_ssl_protocols        => [ 'TLSv1.2', ],
        :server_cipher_suites        => [ 'TLS_RSA_WITH_AES_256_CBC_SHA256',
                                          'TLS_RSA_WITH_AES_256_CBC_SHA',
                                          'TLS_RSA_WITH_AES_128_CBC_SHA256',
                                          'TLS_RSA_WITH_AES_128_CBC_SHA', ],
        :server_max_active_instances => 2,
        :server_max_requests_per_instance => 0,
        :server_ca                   => true,
        :server_puppetserver_version => '2.4.99',
        :server_use_legacy_auth_conf => false,
        :server_puppetserver_dir     => '/etc/custom/puppetserver',
        :server_puppetserver_vardir  => '/opt/puppetlabs/server/data/puppetserver',
        :server_jruby_gem_home       => '/opt/puppetlabs/server/data/puppetserver/jruby-gems',
        :server_dir                  => '/etc/puppetlabs/puppet',
        :server_idle_timeout         => 1200000,
        :server_connect_timeout      => 120000,
        :server_enable_ruby_profiler => false,
      } end

      describe 'with default parameters' do
        let(:params) do
          default_params.merge({
            :server_puppetserver_dir => '/etc/custom/puppetserver',
          })
        end
        it { should contain_file('/etc/custom/puppetserver/bootstrap.cfg') }
        it { should contain_file_line('ca_enabled').with_ensure('present') }
        it { should contain_file_line('ca_disabled'). with_ensure('absent') }
        it { should contain_file('/etc/custom/puppetserver/services.d').with_ensure('directory') }
        it { should contain_file('/etc/custom/puppetserver/services.d/ca.cfg') }
        it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config').with_ensure('directory') }
        it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d').with_ensure('directory') }
        it { should contain_augeas('puppet::server::puppetserver::bootstrap').
                with_changes('set BOOTSTRAP_CONFIG \'"/etc/custom/puppetserver/bootstrap.cfg,/etc/custom/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"\'')
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

      describe 'server_puppetserver_vardir' do
        context 'with default parameters' do
          let(:params) do
            default_params.merge({
              :server_puppetserver_dir => '/etc/custom/puppetserver',
            })
          end
          it 'should have master-var-dir: /opt/puppetlabs/server/data/puppetserver' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    master-var-dir: /opt/puppetlabs/server/data/puppetserver\n])
          end
        end
        context 'with custom server_puppetserver_vardir' do
          let(:params) do
            default_params.merge({
              :server_puppetserver_dir    => '/etc/custom/puppetserver',
              :server_puppetserver_vardir => '/opt/custom/puppetlabs/server/data/puppetserver',
            })
          end
          it 'should have master-var-dir: /opt/puppetlabs/server/data/puppetserver' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    master-var-dir: /opt/custom/puppetlabs/server/data/puppetserver\n])
          end
        end
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
        context 'when server_puppetserver_version >= 2.5' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.5.0',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it { should_not contain_file_line('versioned_code_service') }
        end

        context 'when server_puppetserver_version >= 2.3 and < 2.5' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.3.1',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it 'should have versioned-code-service in bootstrap.cfg' do
            should contain_file_line('versioned_code_service').
                with_ensure('present').
                with_path('/etc/custom/puppetserver/bootstrap.cfg').
                with_line('puppetlabs.services.versioned-code-service.versioned-code-service/versioned-code-service').
                that_requires('File[/etc/custom/puppetserver/bootstrap.cfg]')
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
                with_path('/etc/custom/puppetserver/bootstrap.cfg').
                with_line('puppetlabs.services.versioned-code-service.versioned-code-service/versioned-code-service').
                that_requires('File[/etc/custom/puppetserver/bootstrap.cfg]')
          end
        end
      end

      describe 'bootstrap.cfg' do
        context 'when server_puppetserver_version >= 2.5' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.5.0',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it { should_not contain_file('/etc/custom/puppetserver/bootstrap.cfg') }
          it { should_not contain_file_line('ca_enabled') }
          it { should_not contain_file_line('ca_disabled') }
        end

        context 'when server_puppetserver_version < 2.4.99' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.4.98',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it { should contain_file('/etc/custom/puppetserver/bootstrap.cfg') }
          it {
            should contain_file_line('ca_enabled').
              with_ensure('present').
              with_path('/etc/custom/puppetserver/bootstrap.cfg').
              with_line('puppetlabs.services.ca.certificate-authority-service/certificate-authority-service').
              that_requires('File[/etc/custom/puppetserver/bootstrap.cfg]')
          }
          it {
            should contain_file_line('ca_disabled').
              with_ensure('absent').
              with_path('/etc/custom/puppetserver/bootstrap.cfg').
              with_line('puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service').
              that_requires('File[/etc/custom/puppetserver/bootstrap.cfg]')
          }
          it { should contain_augeas('puppet::server::puppetserver::bootstrap').
                  with_changes('set BOOTSTRAP_CONFIG \'"/etc/custom/puppetserver/bootstrap.cfg"\'').
                  with_context('/files/etc/default/puppetserver').
                  with_incl('/etc/default/puppetserver').
                  with_lens('Shellvars.lns').
                  with({})
          }
        end
      end

      describe 'ca.cfg' do
        context 'when server_puppetserver_version >= 2.5' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.5.0',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it { should contain_file('/etc/custom/puppetserver/services.d').with_ensure('directory') }
          it {
            should contain_file('/etc/custom/puppetserver/services.d/ca.cfg').
              with_content(%r{^puppetlabs.services.ca.certificate-authority-service/certificate-authority-service}).
              with_content(%r{^#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service})
          }
          it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config').with_ensure('directory') }
          it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d').with_ensure('directory') }
          it { should contain_augeas('puppet::server::puppetserver::bootstrap').
                  with_changes('set BOOTSTRAP_CONFIG \'"/etc/custom/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"\'').
                  with_context('/files/etc/default/puppetserver').
                  with_incl('/etc/default/puppetserver').
                  with_lens('Shellvars.lns').
                  with({})
          }
        end

        context 'when server_puppetserver_version >= 2.5 and server_ca => false' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.5.0',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                     :server_ca => false,
                                 })
          end
          it {
            should contain_file('/etc/custom/puppetserver/services.d/ca.cfg').
              with_content(%r{^#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service}).
              with_content(%r{^puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service})
          }
        end

        context 'when server_puppetserver_version < 2.4.99' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.4.98',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it { should_not contain_file('/etc/custom/puppetserver/services.d') }
          it { should_not contain_file('/etc/custom/puppetserver/services.d/ca.cfg') }
          it { should_not contain_file('/opt/puppetlabs/server/apps/puppetserver/config') }
          it { should_not contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d') }
        end
      end

      describe 'server_ca related settings' do
        context 'when server_puppetserver_version >= 2.2' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.2.0',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/auth.conf').
              with_content(/^\s+path: "\/certificate_statuses\/"/).
              with_content(/^\s+name: "certificate_status"/).
              with_content(/^\s+path: "\/puppet-admin-api\/v1\/environment-cache"/).
              with_content(/^\s+name: "environment-cache"/).
              with_content(/^\s+path: "\/puppet-admin-api\/v1\/jruby-pool"/).
              with_content(/^\s+name: "jruby-pool"/).
              with({}) # So we can use a trailing dot on each with_content line
          }
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/ca.conf').
              with_ensure('absent').
              with({}) # So we can use a trailing dot on each with_content line
          }
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/puppetserver.conf').
              without_content(/^# Settings related to the puppet-admin HTTP API$/).
              without_content(/^puppet-admin: \{$/).
              without_content(/^\s+client-whitelist: \[$/).
              without_content(/^\s+"localhost"\,$/).
              without_content(/^\s+"puppetserver123.example.com"\,$/).
              with({}) # So we can use a trailing dot on each with_content line
          }
        end

        context 'when server_puppetserver_version < 2.2' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.1.1',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/auth.conf').
              without_content(/^\s+path: "\/certificate_statuses\/"/).
              without_content(/^\s+name: "certificate_status"/).
              without_content(/^\s+path: "\/puppet-admin-api\/v1\/environment-cache"/).
              without_content(/^\s+name: "environment-cache"/).
              without_content(/^\s+path: "\/puppet-admin-api\/v1\/jruby-pool"/).
              without_content(/^\s+name: "jruby-pool"/).
              with({}) # So we can use a trailing dot on each with_content line
          }
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/ca.conf').
              with_content(/^\s+authorization-required: true$/).
              with_content(/^\s+client-whitelist: \[$/).
              with_content(/^\s+"localhost"\,$/).
              with_content(/^\s+"puppetserver123.example.com"\,$/).
              with({}) # So we can use a trailing dot on each with_content line
          }
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/puppetserver.conf').
              with_content(/^# Settings related to the puppet-admin HTTP API$/).
              with_content(/^puppet-admin: \{$/).
              with_content(/^\s+client-whitelist: \[$/).
              with_content(/^\s+"localhost"\,$/).
              with_content(/^\s+"puppetserver123.example.com"\,$/).
              with({}) # So we can use a trailing dot on each with_content line
          }
        end
      end

      describe 'status API endpoint' do
        context 'when server_puppetserver_version >= 2.6' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.6.0',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/web-routes.conf').
              with_content(/^\s+"puppetlabs.trapperkeeper.services.status.status-service\/status-service": "\/status"/)
          }
        end

        context 'when server_puppetserver_version < 2.6' do
          let(:params) do
            default_params.merge({
                                     :server_puppetserver_version => '2.5.0',
                                     :server_puppetserver_dir => '/etc/custom/puppetserver',
                                 })
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/web-routes.conf').
              without_content(/^\s+"puppetlabs.trapperkeeper.services.status.status-service\/status-service": "\/status"/)
          }
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
