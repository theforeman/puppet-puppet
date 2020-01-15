require 'spec_helper'

describe 'puppet' do
  on_os_under_test.each do |os, facts|
    next if unsupported_puppetmaster_osfamily(facts[:osfamily])
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:auth_conf) { '/etc/custom/puppetserver/conf.d/auth.conf' }
      let(:puppetserver_conf) { '/etc/custom/puppetserver/conf.d/puppetserver.conf' }

      let(:params) do
        {
          server: true,
          # We set these values because they're calculated
          server_jvm_config: '/etc/default/puppetserver',
          server_jvm_min_heap_size: '2G',
          server_jvm_max_heap_size: '2G',
          server_jvm_extra_args: '',
          server_max_active_instances: 2,
          server_puppetserver_dir: '/etc/custom/puppetserver',
          server_puppetserver_version: '5.3.6',
        }
      end

      let(:server_vardir) do
        if ['FreeBSD', 'DragonFly'].include?(facts[:operatingsystem])
          '/var/puppet/server/data/puppetserver'
        else
          '/opt/puppetlabs/server/data/puppetserver'
        end
      end

      describe 'with default parameters' do
        it { should contain_file('/etc/custom/puppetserver/services.d').with_ensure('directory') }
        it {
          should contain_file('/etc/custom/puppetserver/services.d/ca.cfg')
            .with_content(%r{^puppetlabs.services.ca.certificate-authority-service/certificate-authority-service})
            .with_content(%r{^#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service})
            .with_content(%r{^puppetlabs.trapperkeeper.services.watcher.filesystem-watch-service/filesystem-watch-service})
        }
        if facts[:osfamily] == 'FreeBSD'
          it {
            should contain_augeas('puppet::server::puppetserver::jvm')
              .with_changes(['set puppetserver_java_opts \'"-Xms2G -Xmx2G"\''])
              .with_context('/files/etc/rc.conf')
          }
        else
          it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config').with_ensure('directory') }
          it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d').with_ensure('directory') }
          it {
            should contain_augeas('puppet::server::puppetserver::bootstrap')
              .with_changes('set BOOTSTRAP_CONFIG \'"/etc/custom/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"\'')
                     .with_context('/files/etc/default/puppetserver')
                     .with_incl('/etc/default/puppetserver')
                     .with_lens('Shellvars.lns')
          }
          it {
            should contain_augeas('puppet::server::puppetserver::jvm')
              .with_changes(['set JAVA_ARGS \'"-Xms2G -Xmx2G"\'', 'set JAVA_BIN /usr/bin/java'])
              .with_context('/files/etc/default/puppetserver')
              .with_incl('/etc/default/puppetserver')
              .with_lens('Shellvars.lns')
          }
        end
        it { should contain_file('/etc/custom/puppetserver/conf.d/ca.conf')
                      .with_ensure('file')
                      .with_content(/^( *)allow-subject-alt-names: false$/)
                      .with_content(/^( *)allow-authorization-extensions: false$/)
                      .without_content(/^( *)enable-infra-crl: false$/)
        }
        it {
          should contain_file(puppetserver_conf)
            .without_content(/^# Settings related to the puppet-admin HTTP API$/)
            .without_content(/^puppet-admin: \{$/)
            .without_content(/^\s+client-whitelist: \[$/)
            .without_content(/^\s+"localhost"\,$/)
            .without_content(/^\s+"puppetserver123.example.com"\,$/)
            .with_content(/^    max-queued-requests: 0\n/)
            .with_content(/^    max-retry-delay: 1800\n/)
        }
        it {
          should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf')
            .with_content(/ssl-host:\s0\.0\.0\.0/)
            .with_content(/ssl-port:\s8140/)
            .without_content(/ host:\s/)
            .without_content(/ port:\s8139/)
            .without_content(/selector-threads:/)
            .without_content(/acceptor-threads:/)
            .without_content(/ssl-selector-threads:/)
            .without_content(/ssl-acceptor-threads:/)
            .without_content(/max-threads:/)
        }
        it {
          should contain_file(auth_conf)
            .with_content(/allow-header-cert-info: false/)
            .with_content(%r{^\s+path: "/puppet-ca/v1/certificate_status"})
            .with_content(/^\s+name: "puppetlabs cert status"/)
            .with_content(%r{^\s+path: "/puppet-ca/v1/certificate_statuses"})
            .with_content(/^\s+name: "puppetlabs cert statuses"/)
            .with_content(%r{^\s+path: "/puppet-admin-api/v1/environment-cache"})
            .with_content(/^\s+name: "environment-cache"/)
            .with_content(%r{^\s+path: "/puppet-admin-api/v1/jruby-pool"})
            .with_content(/^\s+name: "jruby-pool"/)
            .with_content(%r{^(\ *)path: "/puppet/v3/tasks"$})
            .with_content(%r{^(\ *)path: "\^/puppet/v3/facts/(.*)$})
            .with_content(/^( *)pp_cli_auth: "true"$/)
        }
      end

      describe 'server_puppetserver_vardir' do
        context 'with default parameters' do
          it { should contain_file(puppetserver_conf).with_content(%r{^    master-var-dir: #{server_vardir}$}) }
        end

        context 'with custom server_puppetserver_vardir' do
          let(:params) { super().merge(server_puppetserver_vardir: '/opt/custom/puppetserver') }
          it { should contain_file(puppetserver_conf).with_content(%r{^    master-var-dir: /opt/custom/puppetserver$}) }
        end
      end

      describe 'use-legacy-auth-conf' do
        context 'with default parameters' do
          it { should contain_file(puppetserver_conf).with_content(/^    use-legacy-auth-conf: false$/) }
        end

        context 'when use-legacy-auth-conf = true' do
          let(:params) { super().merge(server_use_legacy_auth_conf: true) }
          it { should contain_file(puppetserver_conf).with_content(/^    use-legacy-auth-conf: true$/) }
        end
      end

      describe 'environment-class-cache-enabled' do
        context 'with default parameters' do
          it { should contain_file(puppetserver_conf).with_content(/^    environment-class-cache-enabled: false$/) }
        end

        context 'when environment-class-cache-enabled = true' do
          let(:params) { super().merge(server_environment_class_cache_enabled: true) }
          it { should contain_file(puppetserver_conf).with_content(/^    environment-class-cache-enabled: true$/) }
        end
      end

      describe 'server_max_requests_per_instance' do
        context 'with default parameters' do
          it { should contain_file(puppetserver_conf).with_content(/^    max-requests-per-instance: 0$/) }
        end

        context 'custom server_max_requests_per_instance' do
          let(:params) { super().merge(server_max_requests_per_instance: 123_456) }
          it { should contain_file(puppetserver_conf).with_content(/^    max-requests-per-instance: 123456$/) }
        end
      end

      describe 'server_max_queued_requests' do
          context 'with custom server_max_queued_requests' do
            let(:params) { super().merge(server_max_queued_requests: 100) }
            it { should contain_file(puppetserver_conf).with_content(/^    max-queued-requests: 100\n/) }
          end
      end

      describe 'server_max_retry_delay' do
          context 'with custom server_max_retry_delay' do
            let(:params) { super().merge(server_max_retry_delay: 100) }
            it { should contain_file(puppetserver_conf).with_content(/^    max-retry-delay: 100\n/) }
          end
      end

      describe 'server_multithreaded' do
        context 'with default parameters' do
          context 'when server_puppetserver_version >= 5.3.6 and < 6.8.0' do
            it { should contain_file(puppetserver_conf).without_content(/multithreaded/) }
          end
          context 'when server_puppetserver_version == 6.8.0' do
            let(:params) { super().merge(server_puppetserver_version: '6.8.0') }
            it { should contain_file(puppetserver_conf).with_content(/^    multithreaded: false\n/) }
          end
        end
        context 'with custom server_multithreaded' do
          let(:params) { super().merge(server_multithreaded: true) }
          context 'when server_puppetserver_version >= 5.3.6 and < 6.8.0' do
            it { should contain_file(puppetserver_conf).without_content(/multithreaded/) }
          end
          context 'when server_puppetserver_version == 6.8.0' do
            let(:params) { super().merge(server_puppetserver_version: '6.8.0') }
            it { should contain_file(puppetserver_conf).with_content(/^    multithreaded: true\n/) }
          end
        end
      end

      describe 'ca.cfg' do
        context 'when server_ca => false' do
          let(:params) { super().merge(server_ca: false) }
          it {
            should contain_file('/etc/custom/puppetserver/services.d/ca.cfg')
              .with_content(%r{^#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service})
              .with_content(%r{^puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service})
              .with_content(%r{^puppetlabs.trapperkeeper.services.watcher.filesystem-watch-service/filesystem-watch-service})
          }
        end
      end

      describe 'product.conf' do
        context 'with default parameters' do
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/product.conf')
              .with_content(/^\s+check-for-updates: true/)
          }
        end

        context 'with server_check_for_updates => false' do
          let(:params) { super().merge(server_check_for_updates: false) }
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/product.conf')
              .with_content(/^\s+check-for-updates: false/)
          }
        end
      end

      describe 'server_metrics' do
        context 'when server_metrics => true' do
          let(:params) do
            super().merge(
              server_puppetserver_metrics: true,
              server_metrics_graphite_enable: true,
              server_metrics_graphite_host: 'graphitehost.example.com',
              server_metrics_graphite_port: 2003,
              server_metrics_server_id: 'puppetserver.example.com',
              server_metrics_graphite_interval: 5,
              server_metrics_allowed: ['single.element.array'],
            )
          end

          it {
            should contain_file(puppetserver_conf)
              .with_content(/^    # Whether to enable http-client metrics; defaults to 'true'.\n    metrics-enabled: true$(.*)/)
              .with_content(/^profiler: \{\n    # enable or disable profiling for the Ruby code;\n    enabled: true/)
          }
          it {
            should contain_file('/etc/custom/puppetserver/conf.d/metrics.conf')
              .with_content(/^( *)metrics-allowed: \[\n( *)"single.element.array",\n( *)\]/)
              .with_content(/^( *)server-id: "puppetserver.example.com"/)
              .with_content(/^( *)jmx: \{\n( *)enabled: true/)
              .with_content(/^( *)graphite: \{\n( *)enabled: true/)
              .with_content(/^( *)host: "graphitehost.example.com"/)
              .with_content(/^( *)port: 2003/)
              .with_content(/^( *)update-interval-seconds: 5/)
          }
        end

        context 'when server_metrics => false' do
          let(:params) { super().merge(server_puppetserver_metrics: false) }
          it {
            should contain_file(puppetserver_conf)
              .with_content(/^    # Whether to enable http-client metrics; defaults to 'true'.\n    metrics-enabled: false$/)
              .with_content(/^profiler: \{\n    # enable or disable profiling for the Ruby code;\n    enabled: false/)
          }
          it { should contain_file('/etc/custom/puppetserver/conf.d/metrics.conf').with_ensure('absent') }
        end
      end

      describe 'server_experimental' do
        context 'when server_experimental => true' do
          let(:params) { super().merge(server_puppetserver_experimental: true) }
          it { should contain_file(auth_conf).with_content(%r{^(\ *)path: "/puppet/experimental"$}) }
        end

        context 'when server_experimental => false' do
          let(:params) { super().merge(server_puppetserver_experimental: false) }
          it { should contain_file(auth_conf).without_content(%r{^(\ *)path: "/puppet/experimental"$}) }
        end
      end

      describe 'server_trusted_agents' do
        context 'when set' do
          let(:params) { super().merge(server_puppetserver_trusted_agents: ['jenkins', 'octocatalog-diff']) }
          it { should contain_file(auth_conf).with_content(/^            allow: \["jenkins", "octocatalog-diff", "\$1"\]$/) }
        end
      end

      describe 'server_jruby9k', unless: facts[:osfamily] == 'FreeBSD' do
        context 'when server_jruby9k => true' do
          let(:params) { super().merge(server_puppetserver_jruby9k: true) }
          it do
            should contain_augeas('puppet::server::puppetserver::jruby_jar')
              .with_changes(['set JRUBY_JAR \'"/opt/puppetlabs/server/apps/puppetserver/jruby-9k.jar"\''])
              .with_context('/files/etc/default/puppetserver')
              .with_incl('/etc/default/puppetserver')
              .with_lens('Shellvars.lns')
          end
        end

        context 'when server_jruby9k => false' do
          let(:params) { super().merge(server_puppetserver_jruby9k: false) }
          it do
            should contain_augeas('puppet::server::puppetserver::jruby_jar')
              .with_changes(['rm JRUBY_JAR'])
              .with_context('/files/etc/default/puppetserver')
              .with_incl('/etc/default/puppetserver')
              .with_lens('Shellvars.lns')
          end
        end
      end

      describe 'server_max_open_files', unless: facts[:osfamily] == 'FreeBSD' do
        context 'when server_max_open_files => undef' do
          it do
            if facts['service_provider'] == 'systemd'
              should contain_systemd__dropin_file('puppetserver.service-limits.conf')
                .with_ensure('absent')
            else
              should contain_file_line('puppet::server::puppetserver::max_open_files')
                .with_ensure('absent')
            end
          end
        end

        context 'when server_max_open_files => 32143' do
          let(:params) { super().merge(server_max_open_files: 32143) }

          it do
            if facts['service_provider'] == 'systemd'
                should contain_systemd__dropin_file('puppetserver.service-limits.conf')
                  .with_ensure('present')
                  .with_filename('limits.conf')
                  .with_unit('puppetserver.service')
                  .with_content("[Service]\nLimitNOFILE=32143\n")
            else
                should contain_file_line('puppet::server::puppetserver::max_open_files')
                  .with_ensure('present')
                  .with_path('/etc/default/puppetserver')
                  .with_line('ulimit -n 32143')
                  .with_match('^ulimit\ -n')
            end
          end
        end
      end

      describe 'with extra_args parameter' do
        let(:params) { super().merge(server_jvm_extra_args: ['-XX:foo=bar', '-XX:bar=foo']) }
        if facts[:osfamily] == 'FreeBSD'
          it {
            should contain_augeas('puppet::server::puppetserver::jvm')
              .with_changes(['set puppetserver_java_opts \'"-Xms2G -Xmx2G -XX:foo=bar -XX:bar=foo"\''])
              .with_context('/files/etc/rc.conf')
          }
        else
          it {
            should contain_augeas('puppet::server::puppetserver::jvm')
              .with_changes([
                              'set JAVA_ARGS \'"-Xms2G -Xmx2G -XX:foo=bar -XX:bar=foo"\'',
                              'set JAVA_BIN /usr/bin/java'
                            ])
              .with_context('/files/etc/default/puppetserver')
              .with_incl('/etc/default/puppetserver')
              .with_lens('Shellvars.lns')
          }
        end
      end

      describe 'with cli_args parameter', unless: facts[:osfamily] == 'FreeBSD' do
        let(:params) { super().merge(server_jvm_cli_args: '-Djava.io.tmpdir=/var/puppettmp') }
        it do
          should contain_augeas('puppet::server::puppetserver::jvm')
            .with_changes([
                            'set JAVA_ARGS \'"-Xms2G -Xmx2G"\'',
                            'set JAVA_BIN /usr/bin/java',
                            'set JAVA_ARGS_CLI \'"-Djava.io.tmpdir=/var/puppettmp"\''
                          ])
            .with_context('/files/etc/default/puppetserver')
            .with_incl('/etc/default/puppetserver')
            .with_lens('Shellvars.lns')
        end
      end

      describe 'with jvm_config file parameter' do
        let(:params) { super().merge(server_jvm_config: '/etc/custom/puppetserver') }
        if facts[:osfamily] == 'FreeBSD'
          it { should contain_augeas('puppet::server::puppetserver::jvm').with_context('/files/etc/rc.conf') }
        else
          it do
            should contain_augeas('puppet::server::puppetserver::jvm')
              .with_context('/files/etc/custom/puppetserver')
              .with_incl('/etc/custom/puppetserver')
              .with_lens('Shellvars.lns')
          end
        end
      end

      describe 'gem-path' do
        if ['FreeBSD', 'DragonFly'].include?(facts[:osfamily])
          it do
            should contain_file(puppetserver_conf)
              .with_content(%r{^    gem-path: \[\$\{jruby-puppet.gem-home\}, "#{server_vardir}/vendored-jruby-gems"\]$})
          end
        else
          it do
            should contain_file(puppetserver_conf)
              .with_content(%r{^    gem-path: \[\$\{jruby-puppet.gem-home\}, "#{server_vardir}/vendored-jruby-gems", "/opt/puppetlabs/puppet/lib/ruby/vendor_gems"\]$})
          end
        end
      end

      describe 'Puppet Server CA related settings' do
        context 'when server_puppetserver_version >= 5.3.6 and < 6.0.0' do
          context 'with ca parameters set' do
            let(:params) { super().merge(
              server_ca_allow_sans: true,
              server_ca_allow_auth_extensions: true,
              )
            }
            it { should contain_file('/etc/custom/puppetserver/conf.d/ca.conf')
                          .with_ensure('file')
                          .with_content(/^( *)allow-subject-alt-names: true$/)
                          .with_content(/^( *)allow-authorization-extensions: true$/)
            }
          end
        end

        context 'when server_puppetserver_version >= 6.0.0' do
          let(:params) { super().merge(server_puppetserver_version: '6.0.0') }
          context 'with default parameters' do
            it { should contain_file('/etc/custom/puppetserver/conf.d/ca.conf')
                          .with_ensure('file')
                          .with_content(/^( *)allow-subject-alt-names: false$/)
                          .with_content(/^( *)allow-authorization-extensions: false$/)
                          .with_content(/^( *)enable-infra-crl: false$/)
            }
            it { should contain_file(auth_conf).with_content(/^( *)pp_cli_auth: "true"$/) }
          end

          context 'with ca parameters set' do
            let(:params) { super().merge(
              server_ca_allow_sans: true,
              server_ca_allow_auth_extensions: true,
              server_ca_enable_infra_crl: true,
              )
            }
            it { should contain_file('/etc/custom/puppetserver/conf.d/ca.conf')
                          .with_ensure('file')
                          .with_content(/^( *)allow-subject-alt-names: true$/)
                          .with_content(/^( *)allow-authorization-extensions: true$/)
                          .with_content(/^( *)enable-infra-crl: true$/)
            }
          end
        end
      end

      describe 'puppetlabs v4 catalog for services' do
        context 'when server_puppetserver_version >= 6.3' do
          let(:params) { super().merge(server_puppetserver_version: '6.3.0') }
          it { should contain_file(auth_conf).with_content(%r{^(\ *)path: "\^/puppet/v4/catalog/\?\$"$}) }
        end

        context 'when server_puppetserver_version < 6.3' do
          let(:params) { super().merge(server_puppetserver_version: '6.2.0') }
          it { should contain_file(auth_conf).without_content(%r{^(\ *)path: "\^/puppet/v4/catalog/\?\$"$}) }
        end
      end

      describe 'when server_puppetserver_version < 5.3.6' do
        let(:params) { super().merge(server_puppetserver_version: '5.3.5') }
        it { should raise_error(Puppet::Error, /puppetserver <5.3.6 is not supported by this module version/) }
      end

      describe 'allow jetty specific server threads' do
        context 'with thread config' do
          let(:params) do
            super().merge(
              server_selector_threads:     1,
              server_acceptor_threads:     2,
              server_ssl_selector_threads: 3,
              server_ssl_acceptor_threads: 4,
              server_max_threads:          5
            )
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
               with_content(/selector-threads: 1/).
               with_content(/acceptor-threads: 2/).
               with_content(/ssl-selector-threads: 3/).
               with_content(/ssl-acceptor-threads: 4/).
               with_content(/max-threads: 5/)
          }
        end
      end
    end
  end
end
