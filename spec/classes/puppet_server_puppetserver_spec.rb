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
    end
  end
end
