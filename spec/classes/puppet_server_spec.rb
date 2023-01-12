require 'spec_helper'

describe 'puppet' do
  on_supported_os.each do |os, facts|
    context "on #{os}", unless: unsupported_puppetserver_osfamily(facts[:osfamily]) do
      if facts[:osfamily] == 'FreeBSD'
        codedir             = '/usr/local/etc/puppet'
        confdir             = '/usr/local/etc/puppet'
        etcdir              = '/usr/local/etc/puppet'
        puppetserver_etcdir = '/usr/local/etc/puppetserver'
        puppetserver_logdir = '/var/log/puppetserver'
        puppetserver_rundir = '/var/run/puppetserver'
        puppetserver_vardir = '/var/puppet/server/data/puppetserver'
        sharedir            = '/usr/local/share/puppet'
        ssldir              = '/var/puppet/ssl'
        vardir              = '/var/puppet'
        rubydir             = %r{^/usr/local/lib/ruby/site_ruby/\d+\.\d+/puppet$}
        puppetserver_pkg    = "puppetserver#{facts[:puppetversion].to_i}"
        puppetcacmd         = if facts[:puppetversion] >= '6.0'
                                '/usr/local/bin/puppetserver ca setup'
                              else
                                '/usr/local/bin/puppet cert --generate puppetserver.example.com --allow-dns-alt-names'
                              end
      else
        codedir             = '/etc/puppetlabs/code'
        confdir             = '/etc/puppetlabs/puppet'
        etcdir              = '/etc/puppetlabs/puppet'
        puppetserver_etcdir = '/etc/puppetlabs/puppetserver'
        puppetserver_logdir = '/var/log/puppetlabs/puppetserver'
        puppetserver_rundir = '/var/run/puppetlabs/puppetserver'
        puppetserver_vardir = '/opt/puppetlabs/server/data/puppetserver'
        sharedir            = '/opt/puppetlabs/puppet'
        ssldir              = '/etc/puppetlabs/puppet/ssl'
        vardir              = '/opt/puppetlabs/puppet/cache'
        rubydir             = '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet'
        puppetserver_pkg    = 'puppetserver'
        puppetcacmd         = if facts[:puppetversion] >= '6.0'
                                '/opt/puppetlabs/bin/puppetserver ca setup'
                              else
                                '/opt/puppetlabs/bin/puppet cert --generate puppetserver.example.com --allow-dns-alt-names'
                              end
      end
      conf_file           = "#{confdir}/puppet.conf"
      conf_d_dir          = "#{puppetserver_etcdir}/conf.d"
      environments_dir    = "#{codedir}/environments"
      cadir               = facts[:puppetversion] >= '7.0' ? "#{puppetserver_etcdir}/ca" : "#{ssldir}/ca"
      if facts[:puppetversion] >= '6.0'
        cert_to_create      = "#{cadir}/ca_crt.pem"
      else
        cert_to_create      = "#{ssldir}/certs/puppetserver.example.com.pem"
      end

      let(:facts) { facts }

      let(:params) do
        {
          server: true,
          server_certname: 'puppetserver.example.com'
        }
      end

      describe 'with no custom parameters' do
        it { should compile.with_all_deps }

        # install
        it { should contain_class('puppet::server::install') }
        it { should contain_user('puppet') }
        it { should contain_package(puppetserver_pkg).with_install_options(nil) }

        # config
        it { should contain_class('puppet::server::config') }
        it { should contain_puppet__config__main('reports').with_value('foreman') }
        it { should contain_puppet__config__main('hiera_config').with_value('$confdir/hiera.yaml') }
        it { should contain_puppet__config__main('environmentpath').with_value(environments_dir) }
        it do
          should contain_puppet__config__main('basemodulepath')
            .with_value(["#{environments_dir}/common", "#{codedir}/modules", "#{sharedir}/modules", '/usr/share/puppet/modules'])
            .with_joiner(':')
        end
        it { should_not contain_puppet__config__main('default_manifest') }
        it { should contain_puppet__config__server('autosign').with_value("#{etcdir}\/autosign.conf \{ mode = 0664 \}") }
        it { should contain_puppet__config__server('ca').with_value('true') }
        it { should contain_puppet__config__server('certname').with_value('puppetserver.example.com') }
        it { should contain_puppet__config__server('parser').with_value('current') }
        it { should contain_puppet__config__server('strict_variables').with_value('false') }
        it { should contain_puppet__config__server('ssldir').with_value(ssldir) }
        it { should contain_puppet__config__server('storeconfigs').with_value(false) }
        it { should_not contain_puppet__config__server('environment_timeout') }
        it { should_not contain_puppet__config__server('manifest') }
        it { should_not contain_puppet__config__server('modulepath') }
        it { should_not contain_puppet__config__server('trusted_external_command') }

        it { should contain_puppet__config__server('external_nodes').with_value("#{etcdir}\/node.rb") }
        it { should contain_puppet__config__server('node_terminus').with_value('exec') }
        it { should contain_puppet__config__server('logdir').with_value(puppetserver_logdir) }
        it { should contain_puppet__config__server('rundir').with_value(puppetserver_rundir) }
        it { should contain_puppet__config__server('vardir').with_value(puppetserver_vardir) }

        it 'should set up SSL permissions' do
          should contain_file("#{ssldir}/private_keys") \
            .with_group('puppet') \
            .with_mode('0750')

          should contain_file("#{ssldir}/private_keys/puppetserver.example.com.pem") \
            .with_group('puppet') \
            .with_mode('0640')

          should contain_exec('puppet_server_config-create_ssl_dir') \
            .with_creates(ssldir) \
            .with_command("/bin/mkdir -p #{ssldir}") \
            .with_umask('0022')

          should contain_exec('puppet_server_config-generate_ca_cert') \
            .with_creates(cert_to_create) \
            .with_command(puppetcacmd) \
            .with_umask('0022') \
            .that_requires(["Concat[#{conf_file}]", 'Exec[puppet_server_config-create_ssl_dir]'])
        end

        it { should contain_exec('puppet_server_config-generate_ca_cert').that_notifies('Service[puppetserver]') }

        it 'should set up the environments' do
          should contain_file(environments_dir)
            .with_ensure('directory')
            .with_owner('puppet')
            .with_group(nil)
            .with_recurse(false)
            .with_mode('0755')

          should contain_file(sharedir).with_ensure('directory')

          should contain_file("#{codedir}/environments/common")
            .with_ensure('directory')
            .with_owner('puppet')
            .with_group(nil)
            .with_mode('0755')

          should contain_file("#{sharedir}/modules")
            .with_ensure('directory')
            .with_owner('puppet')
            .with_group(nil)
            .with_mode('0755')
        end

        it { should contain_concat(conf_file) }

        it { should_not contain_puppet__config__agent('http_connect_timeout') }
        it { should_not contain_puppet__config__agent('http_read_timeout') }
        it { should_not contain_file("#{confdir}/custom_trusted_oid_mapping.yaml") }

        it { should contain_file("#{confdir}/autosign.conf") }
        it { should_not contain_file("#{confdir}/autosign.conf").with_content(/# Managed by Puppet/) }
        it { should_not contain_file("#{confdir}/autosign.conf").with_content(/foo.bar/) }

        it 'should set up the ENC' do
          should contain_class('puppetserver_foreman')
            .with_foreman_url('https://foo.example.com')
            .with_enc_upload_facts(true)
            .with_enc_timeout(60)
            .with_puppet_home(puppetserver_vardir)
            .with_puppet_etcdir(etcdir)
            .with_puppet_basedir(rubydir)
        end

        # service
        it { should contain_class('puppet::server::service') }
        it { should contain_class('puppet::server::puppetserver') }
      end

      describe 'with uppercase hostname' do
        let(:facts) do
          override_facts(super(),
            networking: {fqdn: 'PUPPETSERVER.example.com'},
          )
        end

        it { should compile.with_all_deps }
        it { should contain_class('puppet').with_server_foreman_url('https://puppetserver.example.com') }
      end

      describe 'with ip parameter' do
        let(:params) do
          super().merge(server_ip: '127.0.0.1')
        end

        it { should compile.with_all_deps }
        it { should contain_class('puppet::server').with_ip('127.0.0.1') }
        it { should contain_file("#{conf_d_dir}/webserver.conf").with_content(/host: 127.0.0.1/) }
        it { should contain_file("#{conf_d_dir}/webserver.conf").with_content(/ssl-host: 127.0.0.1/) }
      end

      context 'manage_packages' do
        tests = {
          false    => false,
          'agent'  => false,
          'server' => true
        }

        tests.each do |value, expected|
          describe "when manage_packages => #{value.inspect}" do
            let(:params) do
              super().merge(manage_packages: value)
            end

            it { should compile.with_all_deps }
            if expected
              it { should contain_package(puppetserver_pkg) }
            else
              it { should_not contain_package(puppetserver_pkg) }
            end
          end
        end
      end

      describe 'when autosign => true' do
        let(:params) do
          super().merge(autosign: true)
        end

        it { should contain_puppet__config__server('autosign').with_value(true) }
      end

      describe 'when autosign => /somedir/custom_autosign, autosign_mode => 664' do
        let(:params) do
          super().merge(
            autosign: '/somedir/custom_autosign',
            autosign_mode: '664'
          )
        end

        it { should contain_puppet__config__server('autosign').with_value('/somedir/custom_autosign { mode = 664 }') }
      end

      describe "when autosign_entries set to ['foo.bar']" do
        let(:params) do
          super().merge(autosign_entries: ['foo.bar'])
        end

        it 'should contain autosign.conf with content set' do
          should contain_file("#{confdir}/autosign.conf")
          should contain_file("#{confdir}/autosign.conf").with_content(/# Managed by Puppet/)
          should contain_file("#{confdir}/autosign.conf").with_content(/foo.bar/)
        end
      end

      describe "when autosign_content => set to foo.bar and and autosign_entries set to ['foo.bar']=> true" do
        let(:params) do
          super().merge(
            autosign_content: 'foo.bar',
            autosign_entries: ['foo.bar']
          )
        end

        it { should raise_error(Puppet::Error, %r{Cannot set both autosign_content/autosign_source and autosign_entries}) }
      end

      describe "when autosign_source => set to puppet:///foo/bar and and autosign_entries set to ['foo.bar']=> true" do
        let(:params) do
          super().merge(
            autosign_source: 'puppet:///foo/bar',
            autosign_entries: ['foo.bar']
          )
        end

        it { should raise_error(Puppet::Error, %r{Cannot set both autosign_content\/autosign_source and autosign_entries}) }
      end

      context 'when autosign => /usr/local/bin/custom_autosign.sh, autosign_mode => 775' do
        let(:params) do
          super().merge(
            autosign: '/usr/local/bin/custom_autosign.sh',
            autosign_mode: '775'
          )
        end

        describe "when autosign_content set to 'foo.bar'" do
          let(:params) do
            super().merge(autosign_content: 'foo.bar')
          end

          it { should contain_puppet__config__server('autosign').with_value('/usr/local/bin/custom_autosign.sh { mode = 775 }') }
          it { should contain_file('/usr/local/bin/custom_autosign.sh').with_content('foo.bar') }
        end

        describe "autosign_source set to 'puppet:///foo/bar'" do
          let(:params) do
            super().merge(autosign_source: 'puppet:///foo/bar')
          end

          it { should contain_puppet__config__server('autosign').with_value('/usr/local/bin/custom_autosign.sh { mode = 775 }') }
          it { should contain_file('/usr/local/bin/custom_autosign.sh').with_source('puppet:///foo/bar') }
        end
      end

      describe "when hiera_config => '/etc/puppet/hiera/production/hiera.yaml'" do
        let(:params) do
          super().merge(hiera_config: '/etc/puppet/hiera/production/hiera.yaml')
        end

        it { should contain_puppet__config__main('hiera_config').with_value('/etc/puppet/hiera/production/hiera.yaml') }
      end

      describe 'without foreman' do
        let(:params) do
          super().merge(
            server_foreman: false,
            server_reports: 'store',
            server_external_nodes: ''
          )
        end

        it { should_not contain_class('puppetserver_foreman') }
        it { should_not contain_puppet__config__server('node_terminus') }
        it { should_not contain_puppet__config__server('external_nodes') }
      end

      describe 'with server_default_manifest => true and undef content' do
        let(:params) do
          super().merge(server_default_manifest: true)
        end

        it { should contain_puppet__config__main('default_manifest').with_value('/etc/puppet/manifests/default_manifest.pp') }
        it { should_not contain_file('/etc/puppet/manifests/default_manifest.pp') }
      end

      describe 'with server_default_manifest => true and server_default_manifest_content => "include foo"' do
        let(:params) do
          super().merge(
            server_default_manifest: true,
            server_default_manifest_content: 'include foo'
          )
        end

        it { should contain_puppet__config__main('default_manifest').with_value('/etc/puppet/manifests/default_manifest.pp') }
        it { should contain_file('/etc/puppet/manifests/default_manifest.pp').with_content('include foo') }
      end

      describe 'with git repo' do
        let(:params) do
          super().merge(server_git_repo: true)
        end

        it { is_expected.to compile.with_all_deps }

        it do
          should contain_class('puppet::server')
            .with_git_repo(true)
            .with_git_repo_path("#{vardir}/puppet.git")
            .with_post_hook_name('post-receive')
        end

        it 'should set up the environments directory' do
          should contain_file(environments_dir) \
            .with_ensure('directory') \
            .with_owner('puppet')
        end

        it 'should create the puppet user' do
          shell = case facts[:osfamily]
                  when /^(FreeBSD|DragonFly)$/
                    '/usr/local/bin/git-shell'
                  else
                    '/usr/bin/git-shell'
                  end
          should contain_user('puppet')
            .with_shell(shell)
            .that_requires('Class[git]')
        end

        it do
          should contain_file(vardir)
            .with_ensure('directory')
            .with_owner('root')
        end

        it do
          should contain_git__repo('puppet_repo')
            .with_bare(true)
            .with_target("#{vardir}/puppet.git")
            .with_user('puppet')
            .that_requires("File[#{environments_dir}]")
        end

        it do
          should contain_file("#{vardir}/puppet.git/hooks/post-receive")
            .with_owner('puppet') \
            .with_mode('0755') \
            .that_requires('Git::Repo[puppet_repo]') \
            .with_content(/BRANCH_MAP = \{[^a-zA-Z=>]\}/)
        end

        describe 'with a puppet git branch map' do
          let(:params) do
            super().merge(server_git_branch_map: { 'a' => 'b', 'c' => 'd' })
          end

          it 'should add the branch map to the post receive hook' do
            should contain_file("#{vardir}/puppet.git/hooks/post-receive")
              .with_content(/BRANCH_MAP = \{\n  "a" => "b",\n  "c" => "d",\n\}/)
          end
        end
      end

      context 'with directory environments owner' do
        let(:params) { super().merge(server_environments_owner: 'apache') }
        it { should contain_file(environments_dir).with_owner('apache') }
      end

      context 'with directory environments recursive mangement' do
        let(:params) { super().merge(server_environments_recurse: true) }
        it { should contain_file(environments_dir).with_recurse(true) }
      end

      context 'with no common modules directory' do
        let(:params) { super().merge(server_common_modules_path: '') }
        it { should_not contain_puppet__config__main('basemodulepath') }
      end

      describe 'with SSL path overrides' do
        let(:params) do
          super().merge(
            server_foreman_ssl_ca: '/etc/example/ca.pem',
            server_foreman_ssl_cert: '/etc/example/cert.pem',
            server_foreman_ssl_key: '/etc/example/key.pem'
          )
        end

        it 'should pass SSL parameters to the ENC' do
          should contain_class('puppetserver_foreman')
            .with_ssl_ca('/etc/example/ca.pem')
            .with_ssl_cert('/etc/example/cert.pem')
            .with_ssl_key('/etc/example/key.pem')
        end
      end

      describe 'with additional settings' do
        let(:params) do
          super().merge(server_additional_settings: { 'stringify_facts' => true })
        end

        it 'should configure puppet.conf' do
          should contain_puppet__config__server('stringify_facts').with_value(true)
        end
      end

      describe 'with server_parser => future' do
        let(:params) do
          super().merge(server_parser: 'future')
        end

        it { should contain_puppet__config__server('parser').with_value('future') }
      end

      describe 'with server_environment_timeout set' do
        let(:params) do
          super().merge(server_environment_timeout: '10m')
        end

        it { should contain_puppet__config__server('environment_timeout').with_value('10m') }
      end

      describe 'with no ssldir managed for server' do
        let(:params) do
          super().merge(server_ssl_dir_manage: false)
        end

        it { should_not contain_puppet__config__server('ssl_dir') }
      end

      describe 'with ssl key management disabled for server' do
        let(:params) do
          super().merge(
            server_certname: 'servercert',
            server_ssl_dir: '/etc/custom/puppetlabs/puppet/ssl',
            server_ssl_key_manage: false
          )
        end

        it { should_not contain_file('/etc/custom/puppetlabs/puppet/ssl/private_keys/servercert.pem') }
      end

      describe 'with nondefault CA settings' do
        let(:params) do
          super().merge(server_ca: false)
        end

        it { should contain_exec('puppet_server_config-create_ssl_dir') }
        it { should_not contain_exec('puppet_server_config-generate_ca_cert') }
      end

      describe 'with server_ca_crl_sync => true' do
        let(:params) do
          super().merge(server_ca_crl_sync: true)
        end

        context 'with server_ca => false and running "puppet apply"' do
          let(:params) do
            super().merge(
              server_ca: false,
              server_ssl_dir: '/etc/custom/puppetlabs/puppet/ssl'
            )
          end

          it 'should not sync the crl' do
            # https://github.com/puppetlabs/rspec-puppet/issues/37
            pending("rspec-puppet always sets $server_facts['servername']")
            should_not contain_file('/etc/custom/puppetlabs/puppet/ssl/crl.pem')
          end
        end

        context 'with server_ca => false: running "puppet agent -t"' do
          let(:params) do
            super().merge(
              server_ca: false,
              server_ssl_dir: '/etc/custom/puppetlabs/puppet/ssl'
            )
          end

          let(:facts) do
            facts.merge(servername: 'myserver')
          end

          before :context do
            @cacrl = Tempfile.new('cacrl')
            File.open(@cacrl, 'w') { |f| f.write 'This is my CRL File' }
            Puppet.settings[:cacrl] = @cacrl.path
          end

          it 'should sync the crl from the ca' do
            should contain_file('/etc/custom/puppetlabs/puppet/ssl/crl.pem')
              .with_content('This is my CRL File')
          end
        end

        context 'with server_ca => true: running "puppet agent -t"' do
          let(:params) do
            super().merge(
              server_ca: true,
              server_ssl_dir: '/etc/custom/puppetlabs/puppet/ssl'
            )
          end

          let(:facts) do
            facts.merge(servername: 'myserver')
          end

          it 'should not sync the crl' do
            should_not contain_file('/etc/custom/puppetlabs/puppet/ssl/crl.pem')
          end
        end
      end

      describe 'allow crl checking' do
        context 'as ca' do
          let(:params) do
            super().merge(server_ca: true)
          end

          it { should contain_file("#{conf_d_dir}/webserver.conf").with_content(%r{ssl-crl-path: #{cadir}/ca_crl\.pem}) }
        end

        context 'as non-ca' do
          let(:params) do
            super().merge(server_ca: false)
          end

          it { should contain_file("#{conf_d_dir}/webserver.conf").without_content(%r{ssl-crl-path: #{ssldir}/crl\.pem}) }

          context 'server_crl_enable' do
            let(:params) do
              super().merge(server_crl_enable: true)
            end

            it { should contain_file("#{conf_d_dir}/webserver.conf").with_content(%r{ssl-crl-path: #{ssldir}/crl\.pem}) }
          end
        end
      end

      describe 'with ssl_protocols overwritten' do
        let(:params) do
          super().merge(server_ssl_protocols: ['TLSv1.1', 'TLSv1.2'])
        end

        it { should contain_file("#{conf_d_dir}/webserver.conf").with_content(/ssl-protocols: \[\n( +)TLSv1.1,\n( +)TLSv1.2,\n( +)\]/) }
      end

      describe 'with ssl_protocols overwritten' do
        let(:params) do
          super().merge(server_cipher_suites: %w[TLS_RSA_WITH_AES_256_CBC_SHA256 TLS_RSA_WITH_AES_256_CBC_SHA])
        end

        it { should contain_file("#{conf_d_dir}/webserver.conf").with_content(/cipher-suites: \[\n( +)TLS_RSA_WITH_AES_256_CBC_SHA256,\n( +)TLS_RSA_WITH_AES_256_CBC_SHA,\n( +)\]/) }
      end

      describe 'with ssl_chain_filepath overwritten' do
        let(:params) do
          super().merge(server_ssl_chain_filepath: '/etc/example/certchain.pem')
        end

        it { should contain_file("#{conf_d_dir}/webserver.conf").with_content(%r{ssl-cert-chain: /etc/example/certchain.pem}) }
      end

      describe 'with server_custom_trusted_oid_mapping overwritten' do
        let(:params) do
          super().merge(server_custom_trusted_oid_mapping: {
                          '1.3.6.1.4.1.34380.1.2.1.1' => {
                            shortname: 'myshortname',
                            longname: 'My Long Name'
                          },
                          '1.3.6.1.4.1.34380.1.2.1.2' => {
                            shortname: 'myothershortname'
                          }
                        })
        end

        it 'should have a configured custom_trusted_oid_mapping.yaml' do
          verify_exact_contents(catalogue, "#{confdir}/custom_trusted_oid_mapping.yaml", [
                                  '---',
                                  'oid_mapping:',
                                  '  1.3.6.1.4.1.34380.1.2.1.1:',
                                  '    shortname: myshortname',
                                  '    longname: My Long Name',
                                  '  1.3.6.1.4.1.34380.1.2.1.2:',
                                  '    shortname: myothershortname'
                                ])
        end
      end

      describe 'with server_certname parameter' do
        let(:params) do
          super().merge(
            server_certname: 'puppetserver43.example.com',
            server_ssl_dir: '/etc/custom/puppet/ssl'
          )
        end

        it 'should put the correct ssl key path in webserver.conf' do
          should contain_file("#{conf_d_dir}/webserver.conf")
            .with_content(%r{ssl-key: /etc/custom/puppet/ssl/private_keys/puppetserver43\.example\.com\.pem})
        end

        it 'should put the correct ssl cert path in webserver.conf' do
          should contain_file("#{conf_d_dir}/webserver.conf")
            .with_content(%r{ssl-cert: /etc/custom/puppet/ssl/certs/puppetserver43\.example\.com\.pem})
        end
      end

      describe 'with server_http parameter set to true for the puppet class' do
        let(:params) do
          super().merge(server_http: true)
        end

        it { should contain_file("#{conf_d_dir}/webserver.conf").with_content(/ host:\s0\.0\.0\.0/).with_content(/ port:\s8139/) }
        it { should contain_file("#{conf_d_dir}/auth.conf").with_content(/allow-header-cert-info: true/) }
      end

      describe 'with server_allow_header_cert_info => true' do
        let(:params) do
          super().merge(server_allow_header_cert_info: true)
        end

        it { should contain_file("#{conf_d_dir}/auth.conf").with_content(/allow-header-cert-info: true/) }
      end

      describe 'server_trusted_external_command' do
        context 'with default parameters' do
          it { should_not contain_puppet__config__server('trusted_external_command') }
        end

        describe 'when server_trusted_external_command => /usr/local/sbin/trusted_external_command' do
          let(:params) do
            super().merge(server_trusted_external_command: '/usr/local/sbin/trusted_external_command' )
          end

          it { should contain_puppet__config__server('trusted_external_command').with_value('/usr/local/sbin/trusted_external_command') }
        end
      end

      describe 'with multiple environment paths' do
        let(:params) do
          super().merge(
            server_envs_dir: ['/etc/puppetlabs/code/environments/', '/etc/puppetlabs/code/unmanaged-environments/'],
            server_git_repo_path: '/test/puppet',
            server_post_hook_name: 'post-receive',
            server_git_repo: true,
          )
        end

        it { should contain_puppet__config__main('environmentpath').with_value('/etc/puppetlabs/code/environments/:/etc/puppetlabs/code/unmanaged-environments/') }
        it { should contain_file('/etc/puppetlabs/code/environments/') }
        it { should contain_file('/etc/puppetlabs/code/unmanaged-environments/') }
        it { should contain_git__repo('puppet_repo').that_requires('File[/etc/puppetlabs/code/environments/]') }
        it { should contain_file('/test/puppet/hooks/post-receive').with_content(/ENVIRONMENT_BASEDIR\s=\s"\/etc\/puppetlabs\/code\/environments\/"/) }
      end
    end
  end
end
