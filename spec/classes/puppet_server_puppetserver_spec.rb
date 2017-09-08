require 'spec_helper'

describe 'puppet::server::puppetserver' do
  on_os_under_test.each do |os, facts|
    next if facts[:osfamily] == 'windows'
    next if facts[:osfamily] == 'Archlinux'
    context "on #{os}" do
      let :pre_condition do
        "class {'puppet': server_implementation => 'puppetserver'}"
      end

      if Puppet.version < '4.0'
        additional_facts = {}
      else
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      let(:facts) do
        facts.merge(additional_facts)
      end

      let(:default_params) do {
        :java_bin                               => '/usr/bin/java',
        :config                                 => '/etc/default/puppetserver',
        :jvm_min_heap_size                      => '2G',
        :jvm_max_heap_size                      => '2G',
        :jvm_extra_args                         => '',
        :jvm_cli_args                           => false, # In reality defaults to undef
        :server_ca_auth_required                => true,
        :server_ca_client_whitelist             => [ 'localhost', 'puppetserver123.example.com' ],
        :server_admin_api_whitelist             => [ 'localhost', 'puppetserver123.example.com' ],
        :server_ruby_load_paths                 => [ '/some/path', ],
        :server_ssl_protocols                   => [ 'TLSv1.2', ],
        :server_cipher_suites                   => [ 'TLS_RSA_WITH_AES_256_CBC_SHA256',
                                                     'TLS_RSA_WITH_AES_256_CBC_SHA',
                                                     'TLS_RSA_WITH_AES_128_CBC_SHA256',
                                                     'TLS_RSA_WITH_AES_128_CBC_SHA', ],
        :server_max_active_instances            => 2,
        :server_max_requests_per_instance       => 0,
        :server_http                            => false,
        :server_http_allow                      => [],
        :server_ca                              => true,
        :server_puppetserver_version            => '2.4.99',
        :server_use_legacy_auth_conf            => false,
        :server_puppetserver_dir                => '/etc/custom/puppetserver',
        :server_puppetserver_vardir             => '/opt/puppetlabs/server/data/puppetserver',
        :server_puppetserver_rundir             => '/var/run/puppetlabs/puppetserver',
        :server_puppetserver_logdir             => '/var/log/puppetlabs/puppetserver',
        :server_jruby_gem_home                  => '/opt/puppetlabs/server/data/puppetserver/jruby-gems',
        :server_dir                             => '/etc/puppetlabs/puppet',
        :codedir                                => '/etc/puppetlabs/code',
        :server_idle_timeout                    => 1200000,
        :server_web_idle_timeout                => 30000,
        :server_connect_timeout                 => 120000,
        :server_check_for_updates               => true,
        :server_environment_class_cache_enabled => false,
        :server_jruby9k                         => false,
        :server_metrics                         => true,
        :metrics_jmx_enable                     => true,
        :metrics_graphite_enable                => true,
        :metrics_graphite_host                  => 'graphitehost.example.com',
        :metrics_graphite_port                  => 2003,
        :metrics_server_id                      => 'puppetserver.example.com',
        :metrics_graphite_interval              => 5,
        :metrics_allowed                        => [],
        :server_experimental                    => true,
        :server_ip                              => '0.0.0.0',
        :server_port                            => '8140',
        :server_http_port                       => '8139',
        :server_ssl_ca_crl                      => '/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem',
        :server_ssl_ca_cert                     => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
        :server_ssl_cert                        => '/etc/puppetlabs/puppet/ssl/certs/puppetserver123.example.com.pem',
        :server_ssl_cert_key                    => '/etc/puppetlabs/puppet/ssl/private_keys/puppetserver123.example.com.pem',
        :server_ssl_chain                       => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
        :server_crl_enable                      => true,
        :server_trusted_agents                  => [],
        :allow_header_cert_info                 => false,
      } end

      describe 'with default parameters' do
        let(:params) do
          default_params.merge(:server_puppetserver_dir => '/etc/custom/puppetserver')
        end
        it { should contain_file('/etc/custom/puppetserver/bootstrap.cfg') }
        it { should contain_file_line('ca_enabled').with_ensure('present') }
        it { should contain_file_line('ca_disabled'). with_ensure('absent') }
        it { should contain_file('/etc/custom/puppetserver/services.d').with_ensure('directory') }
        it { should contain_file('/etc/custom/puppetserver/services.d/ca.cfg') }
        if facts[:osfamily] == 'FreeBSD'
          it {
            should contain_augeas('puppet::server::puppetserver::jvm').
              with_changes([
                'set puppetserver_java_opts \'"-Xms2G -Xmx2G"\'',
              ]).
            with_context('/files/etc/rc.conf').
            with({})
          }
        else
          it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config').with_ensure('directory') }
          it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d').with_ensure('directory') }
          it {
            should contain_augeas('puppet::server::puppetserver::bootstrap').
              with_changes('set BOOTSTRAP_CONFIG \'"/etc/custom/puppetserver/bootstrap.cfg,/etc/custom/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"\'')
          }
          it {
            should contain_augeas('puppet::server::puppetserver::jvm').
              with_changes([ 'set JAVA_ARGS \'"-Xms2G -Xmx2G"\'', 'set JAVA_BIN /usr/bin/java' ]).
              with_context('/files/etc/default/puppetserver').
              with_incl('/etc/default/puppetserver').
              with_lens('Shellvars.lns').
              with({})
          }
        end

        it { should contain_file('/etc/custom/puppetserver/conf.d/ca.conf').with_ensure('absent') }
        it {
          should contain_file('/etc/custom/puppetserver/conf.d/puppetserver.conf').
            without_content(/^# Settings related to the puppet-admin HTTP API$/).
            without_content(/^puppet-admin: \{$/).
            without_content(/^\s+client-whitelist: \[$/).
            without_content(/^\s+"localhost"\,$/).
            without_content(/^\s+"puppetserver123.example.com"\,$/).
            with({}) # So we can use a trailing dot on each with_content line
        }
        it {
          should contain_hocon_setting('webserver.ssl-host').
            with_path('/etc/custom/puppetserver/conf.d/webserver.conf').
            with_setting('webserver.ssl-host').
            with_value('0.0.0.0').
            with_ensure('present')
        }
        it {
          should contain_hocon_setting('webserver.ssl-port').
            with_path('/etc/custom/puppetserver/conf.d/webserver.conf').
            with_setting('webserver.ssl-port').
            with_value('8140').
            with_ensure('present')
        }
        it { should contain_hocon_setting('webserver.host').with_ensure('absent') }
        it { should contain_hocon_setting('webserver.port').with_ensure('absent') }
        it {
          should contain_file('/etc/custom/puppetserver/conf.d/auth.conf').
            with_content(/allow-header-cert-info: false/).
            with_content(/^\s+path: "\/puppet-ca\/v1\/certificate_status\/"/).
            with_content(/^\s+name: "certificate_status"/).
            with_content(/^\s+path: "\/puppet-ca\/v1\/certificate_statuses\/"/).
            with_content(/^\s+name: "certificate_statuses"/).
            with_content(/^\s+path: "\/puppet-admin-api\/v1\/environment-cache"/).
            with_content(/^\s+name: "environment-cache"/).
            with_content(/^\s+path: "\/puppet-admin-api\/v1\/jruby-pool"/).
            with_content(/^\s+name: "jruby-pool"/).
            with({}) # So we can use a trailing dot on each with_content line
        }
      end

      describe 'server_puppetserver_vardir' do
        context 'with default parameters' do
          let(:params) do
            default_params.merge(:server_puppetserver_dir => '/etc/custom/puppetserver')
          end
          it 'should have master-var-dir: /opt/puppetlabs/server/data/puppetserver' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    master-var-dir: /opt/puppetlabs/server/data/puppetserver\n])
          end
        end
        context 'with custom server_puppetserver_vardir' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_dir    => '/etc/custom/puppetserver',
              :server_puppetserver_vardir => '/opt/custom/puppetlabs/server/data/puppetserver',
            )
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
            default_params.merge(:server_puppetserver_dir => '/etc/custom/puppetserver')
          end
          it 'should have use-legacy-auth-conf: false in puppetserver.conf' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    use-legacy-auth-conf: false\n])
          end
        end
        context 'when use-legacy-auth-conf = true' do
          let(:params) do
            default_params.merge(
              :server_use_legacy_auth_conf => true,
              :server_puppetserver_dir     => '/etc/custom/puppetserver',
            )
          end
          it 'should have use-legacy-auth-conf: true in puppetserver.conf' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    use-legacy-auth-conf: true\n])
          end
        end
      end

      describe 'environment-class-cache-enabled' do
        context 'with default parameters' do
          let(:params) do
            default_params.merge(:server_puppetserver_dir => '/etc/custom/puppetserver')
          end
          it 'should have environment-class-cache-enabled: false in puppetserver.conf' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    environment-class-cache-enabled: false\n])
          end
        end
        context 'when environment-class-cache-enabled = true' do
          let(:params) do
            default_params.merge(
              :server_environment_class_cache_enabled => true,
              :server_puppetserver_dir                => '/etc/custom/puppetserver',
            )
          end
          it 'should have environment-class-cache-enabled: true in puppetserver.conf' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    environment-class-cache-enabled: true\n])
          end
        end
        context 'when server_puppetserver_version < 2.4' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.2.2',
              :server_puppetserver_dir     => '/etc/custom/puppetserver',
            )
          end
          it 'should not have a environment-class-cache-enabled setting in puppetserver.conf' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).not_to include('environment-class-cache-enabled')
          end
        end
      end

      describe 'server_max_requests_per_instance' do
        context 'with default parameters' do
          let(:params) do
            default_params.merge(:server_puppetserver_dir => '/etc/custom/puppetserver')
            end
          it 'should have max-requests-per-instance: /opt/puppetlabs/server/data/puppetserver' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    max-requests-per-instance: 0\n])
          end
        end
        context 'custom server_max_requests_per_instance' do
          let(:params) do
            default_params.merge(:server_max_requests_per_instance => 123456)
          end

          it 'should have custom max-requests-per-instance: /opt/puppetlabs/server/data/puppetserver' do
            content = catalogue.resource('file', '/etc/custom/puppetserver/conf.d/puppetserver.conf').send(:parameters)[:content]
            expect(content).to include(%Q[    max-requests-per-instance: 123456\n])
          end
        end
      end

      describe 'versioned-code-service' do
        context 'when server_puppetserver_version >= 2.5' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.5.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
            )
          end
          it { should_not contain_file_line('versioned_code_service') }
        end

        context 'when server_puppetserver_version >= 2.3 and < 2.5' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.3.1',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
            )
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
            default_params.merge(
              :server_puppetserver_version => '2.2.2',
              :server_puppetserver_dir     => '/etc/custom/puppetserver',
            )
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
            default_params.merge(
              :server_puppetserver_version => '2.5.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
            )
          end
          it { should_not contain_file('/etc/custom/puppetserver/bootstrap.cfg') }
          it { should_not contain_file_line('ca_enabled') }
          it { should_not contain_file_line('ca_disabled') }
        end

        context 'when server_puppetserver_version < 2.4.99' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.4.98',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
            )
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
          unless facts[:osfamily] == 'FreeBSD'
            it {
              should contain_augeas('puppet::server::puppetserver::bootstrap').
                with_changes('set BOOTSTRAP_CONFIG \'"/etc/custom/puppetserver/bootstrap.cfg"\'').
                with_context('/files/etc/default/puppetserver').
                with_incl('/etc/default/puppetserver').
                with_lens('Shellvars.lns').
                with({})
            }
          end
        end
      end

      describe 'ca.cfg' do
        context 'when server_puppetserver_version >= 2.5' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.5.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
            )
          end
          it { should contain_file('/etc/custom/puppetserver/services.d').with_ensure('directory') }
          it {
            should contain_file('/etc/custom/puppetserver/services.d/ca.cfg').
              with_content(%r{^puppetlabs.services.ca.certificate-authority-service/certificate-authority-service}).
              with_content(%r{^#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service})
          }
          unless facts[:osfamily] == 'FreeBSD'
            it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config').with_ensure('directory') }
            it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d').with_ensure('directory') }
            it {
              should contain_augeas('puppet::server::puppetserver::bootstrap').
                with_changes('set BOOTSTRAP_CONFIG \'"/etc/custom/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"\'').
                with_context('/files/etc/default/puppetserver').
                with_incl('/etc/default/puppetserver').
                with_lens('Shellvars.lns').
                with({})
            }
          end
        end

        context 'when server_puppetserver_version >= 2.5 and server_ca => false' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.5.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
              :server_ca => false,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/services.d/ca.cfg').
              with_content(%r{^#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service}).
              with_content(%r{^puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service})
          }
        end

        context 'when server_puppetserver_version < 2.4.99' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.4.98',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
            )
          end
          it { should_not contain_file('/etc/custom/puppetserver/services.d') }
          it { should_not contain_file('/etc/custom/puppetserver/services.d/ca.cfg') }
          it { should_not contain_file('/opt/puppetlabs/server/apps/puppetserver/config') }
          it { should_not contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d') }
        end
      end

      describe 'product.conf' do
        context 'when server_puppetserver_version >= 2.7' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.7.0',
              :server_puppetserver_dir     => '/etc/custom/puppetserver',
              :server_check_for_updates    => false,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/product.conf').
              with_ensure('file')
          }
          it {
            should contain_hocon_setting('product.check-for-updates').
              with_path('/etc/custom/puppetserver/conf.d/product.conf').
              with_setting('product.check-for-updates').
              with_value(false).
              with_ensure('present')
            }
        end

        context 'when server_puppetserver_version < 2.7' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.6.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
            )
          end
          it { should contain_file('/etc/custom/puppetserver/conf.d/product.conf').with_ensure('absent') }
          it { should_not contain_hocon_setting('product.check-for-updates') }
        end
      end

      describe 'server_metrics' do
        context 'when server_puppetserver_version < 5.0 and server_metrics => true' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.7.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
              :server_metrics => true,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/puppetserver.conf').
              without_content(%r{^    metrics-enabled: (.*)$}).
              with_content(%r{^profiler: \{\n    # enable or disable profiling for the Ruby code;\n    enabled: true})
            }
          it { should_not contain_file('/etc/custom/puppetserver/conf.d/metrics.conf') }
        end

        context 'when server_puppetserver_version < 5.0 and server_metrics => false' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.7.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
              :server_metrics => false,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/puppetserver.conf').
              without_content(%r{^    metrics-enabled: (.*)$}).
              with_content(%r{^profiler: \{\n    # enable or disable profiling for the Ruby code;\n    enabled: false})
          }
          it { should_not contain_file('/etc/custom/puppetserver/conf.d/metrics.conf') }
        end

        context 'when server_puppetserver_version >= 5.0 and server_metrics => true' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '5.0.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
              :server_metrics => true,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/puppetserver.conf').
            with_content(%r{^    # Whether to enable http-client metrics; defaults to 'true'.\n    metrics-enabled: true$(.*)}).
            with_content(%r{^profiler: \{\n    # enable or disable profiling for the Ruby code;\n    enabled: true})
          }
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/metrics.conf').
            with_content(%r{^    server-id: "puppetserver.example.com"}).
            with_content(%r{^                jmx: \{\n                    enabled: true}).
            with_content(%r{^                graphite: \{\n                    enabled: true}).
            with_content(%r{^            host: "graphitehost.example.com"}).
            with_content(%r{^            port: 2003}).
            with_content(%r{^            update-interval-seconds: 5})
          }
        end

        context 'when server_puppetserver_version >= 5.0 and server_metrics => false' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '5.0.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
              :server_metrics => false,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/puppetserver.conf').
              with_content(%r{^    # Whether to enable http-client metrics; defaults to 'true'.\n    metrics-enabled: false$}).
              with_content(%r{^profiler: \{\n    # enable or disable profiling for the Ruby code;\n    enabled: false})
          }
          it { should_not contain_file('/etc/custom/puppetserver/conf.d/metrics.conf') }
        end
      end

      describe 'server_experimental' do
        context 'when server_puppetserver_version < 5.0 and server_experimental => true' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.7.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
              :server_experimental => true,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/auth.conf').
              without_content(%r{^(\ *)path: "/puppet/experimental"$})
          }
        end

        context 'when server_puppetserver_version < 5.0 and server_experimental => false' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.7.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
              :server_experimental => false,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/auth.conf').
              without_content(%r{^(\ *)path: "/puppet/experimental"$})
          }
        end

        context 'when server_puppetserver_version >= 5.0 and server_experimental => true' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '5.0.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
              :server_experimental => true,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/auth.conf').
              with_content(%r{^(\ *)path: "/puppet/experimental"$})
          }
        end

        context 'when server_puppetserver_version >= 5.0 and server_experimental => false' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '5.0.0',
              :server_puppetserver_dir => '/etc/custom/puppetserver',
              :server_experimental => false,
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/auth.conf').
              without_content(%r{^(\ *)path: "/puppet/experimental"$})
          }
        end
      end

      describe 'server_trusted_agents' do
        context 'when set' do
          let(:params) do
            default_params.merge(
              :server_puppetserver_version => '2.7.0',
              :server_puppetserver_dir     => '/etc/custom/puppetserver',
              :server_trusted_agents       => ['jenkins', 'octocatalog-diff'],
            )
          end
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/auth.conf').
              with_content(%r{^            allow: \["jenkins", "octocatalog-diff", "\$1"\]$})
          }
        end
      end

      unless facts[:osfamily] == 'FreeBSD'
        describe 'server_jruby9k' do
          context 'when server_puppetserver_version < 5.0 and server_jruby9k => true' do
            let(:params) do
              default_params.merge(
                :server_puppetserver_version => '2.7.0',
                :server_puppetserver_dir => '/etc/custom/puppetserver',
                :server_jruby9k => true,
              )
            end
              it { should_not contain_augeas('puppet::server::puppetserver::jruby_jar') }
          end

          context 'when server_puppetserver_version < 5.0 and server_jruby9k => false' do
            let(:params) do
              default_params.merge(
                :server_puppetserver_version => '2.7.0',
                :server_puppetserver_dir => '/etc/custom/puppetserver',
                :server_jruby9k => false,
              )
            end
            it { should_not contain_augeas('puppet::server::puppetserver::jruby_jar') }
          end

          context 'when server_puppetserver_version >= 5.0 and server_jruby9k => true' do
            let(:params) do
              default_params.merge(
                :server_puppetserver_version => '5.0.0',
                :server_puppetserver_dir => '/etc/custom/puppetserver',
                :server_jruby9k => true,
              )
            end
            it { should contain_augeas('puppet::server::puppetserver::jruby_jar').
              with_changes(['set JRUBY_JAR \'"/opt/puppetlabs/server/apps/puppetserver/jruby-9k.jar"\'']).
              with_context('/files/etc/default/puppetserver').
              with_incl('/etc/default/puppetserver').
              with_lens('Shellvars.lns').
              with({})
            }
          end

          context 'when server_puppetserver_version >= 5.0 and server_jruby9k => false' do
            let(:params) do
              default_params.merge(
                  :server_puppetserver_version => '5.0.0',
                  :server_puppetserver_dir => '/etc/custom/puppetserver',
                  :server_jruby9k => false,
              )
            end
            it {
              should contain_augeas('puppet::server::puppetserver::jruby_jar').
                with_changes(['rm JRUBY_JAR']).
                with_context('/files/etc/default/puppetserver').
                with_incl('/etc/default/puppetserver').
                with_lens('Shellvars.lns').
                with({})
            }
          end
        end
      end

      describe 'with extra_args parameter' do
        let :params do
          default_params.merge(
            :jvm_extra_args => ['-XX:foo=bar', '-XX:bar=foo'],
          )
        end
        if facts[:osfamily] == 'FreeBSD'
          it {
            should contain_augeas('puppet::server::puppetserver::jvm').
              with_changes([
                'set puppetserver_java_opts \'"-Xms2G -Xmx2G -XX:foo=bar -XX:bar=foo"\'',
              ]).
              with_context('/files/etc/rc.conf').
              with({})
          }
        else
          it {
            should contain_augeas('puppet::server::puppetserver::jvm').
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
      end

      describe 'with cli_args parameter' do
        let :params do
          default_params.merge(:jvm_cli_args => '-Djava.io.tmpdir=/var/puppettmp')
        end
        if facts[:osfamily] != 'FreeBSD'
          it {
            should contain_augeas('puppet::server::puppetserver::jvm').
              with_changes([
                'set JAVA_ARGS \'"-Xms2G -Xmx2G"\'',
                'set JAVA_BIN /usr/bin/java',
                'set JAVA_ARGS_CLI \'"-Djava.io.tmpdir=/var/puppettmp"\'',
              ]).
              with_context('/files/etc/default/puppetserver').
              with_incl('/etc/default/puppetserver').
              with_lens('Shellvars.lns').
              with({})
          }
        end
      end

      describe 'with jvm_config file parameter' do
        let :params do
          default_params.merge(:config => '/etc/custom/puppetserver')
        end
        if facts[:osfamily] == 'FreeBSD'
          it { should contain_augeas('puppet::server::puppetserver::jvm').with_context('/files/etc/rc.conf') }
        else
          it {
            should contain_augeas('puppet::server::puppetserver::jvm').
              with_context('/files/etc/custom/puppetserver').
              with_incl('/etc/custom/puppetserver').
              with_lens('Shellvars.lns').
              with({})
          }
        end
      end

      describe 'when server_puppetserver_version < 2.2' do
        let(:params) do
          default_params.merge(:server_puppetserver_version => '2.1.0')
        end
        it { should raise_error(Puppet::Error, /puppetserver <2.2 is not supported by this module version/) }
      end
    end
  end
end
