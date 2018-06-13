require 'spec_helper'

describe 'puppet::server::config' do
  before :each do
    @cacrl = Tempfile.new('cacrl')
    File.open(@cacrl, 'w') { |f| f.write "This is my CRL File" }
    Puppet.settings[:cacrl] = @cacrl.path
  end
  on_os_under_test.each do |os, facts|
    next if unsupported_puppetmaster_osfamily(facts[:osfamily])
    context "on #{os}" do
      if Puppet.version < '4.0'
        codedir             = '/etc/puppet'
        confdir             = '/etc/puppet'
        conf_file           = '/etc/puppet/puppet.conf'
        environments_dir    = '/etc/puppet/environments'
        logdir              = '/var/log/puppet'
        rundir              = '/var/run/puppet'
        vardir              = '/var/lib/puppet'
        puppetserver_vardir = '/var/lib/puppet'
        puppetserver_logdir = '/var/log/puppet'
        puppetserver_rundir = '/var/run/puppet'
        ssldir              = '/var/lib/puppet/ssl'
        sharedir            = '/usr/share/puppet'
        etcdir              = '/etc/puppet'
        puppetcacmd         = '/usr/bin/puppet cert'
        additional_facts    = {}
        common_modules_path = ["#{codedir}/environments/common","#{codedir}/modules","#{sharedir}/modules"]
      else
        codedir             = '/etc/puppetlabs/code'
        confdir             = '/etc/puppetlabs/puppet'
        conf_file           = '/etc/puppetlabs/puppet/puppet.conf'
        environments_dir    = '/etc/puppetlabs/code/environments'
        logdir              = '/var/log/puppetlabs/puppet'
        rundir              = '/var/run/puppetlabs'
        vardir              = '/opt/puppetlabs/puppet/cache'
        puppetserver_vardir = '/opt/puppetlabs/server/data/puppetserver'
        puppetserver_logdir = '/var/log/puppetlabs/puppetserver'
        puppetserver_rundir = '/var/run/puppetlabs/puppetserver'
        ssldir              = '/etc/puppetlabs/puppet/ssl'
        sharedir            = '/opt/puppetlabs/puppet'
        etcdir              = '/etc/puppetlabs/puppet'
        puppetcacmd         = '/opt/puppetlabs/bin/puppet cert'
        additional_facts    = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
        common_modules_path = ["#{codedir}/environments/common","#{codedir}/modules","#{sharedir}/modules","/usr/share/puppet/modules"]
      end

      if facts[:osfamily] == 'FreeBSD'
        codedir             = '/usr/local/etc/puppet'
        confdir             = '/usr/local/etc/puppet'
        conf_file           = '/usr/local/etc/puppet/puppet.conf'
        environments_dir    = '/usr/local/etc/puppet/environments'
        logdir              = '/var/log/puppet'
        rundir              = '/var/run/puppet'
        vardir              = '/var/puppet'
        puppetserver_vardir = '/var/puppet/server/data/puppetserver'
        puppetserver_logdir = '/var/log/puppetserver'
        puppetserver_rundir = '/var/run/puppetserver'
        ssldir              = '/var/puppet/ssl'
        sharedir            = '/usr/local/share/puppet'
        etcdir              = '/usr/local/etc/puppet'
        puppetcacmd         = '/usr/local/bin/puppet cert'
        additional_facts    = {}
      end

      let(:facts) do
        facts.merge({:clientcert => 'puppetmaster.example.com'}).merge(additional_facts)
      end

      describe 'with no custom parameters' do
        let :pre_condition do
          "class {'puppet': server => true}"
        end

        it 'should set up SSL permissions' do
          should contain_file("#{ssldir}/private_keys").with({
            :group => 'puppet',
            :mode  => '0750',
          })

          should contain_file("#{ssldir}/private_keys/puppetmaster.example.com.pem").with({
            :group => 'puppet',
            :mode  => '0640',
          })

          should contain_exec('puppet_server_config-create_ssl_dir').with({
            :creates => ssldir,
            :command => "/bin/mkdir -p #{ssldir}",
            :umask   => '0022',
          })

          should contain_exec('puppet_server_config-generate_ca_cert').with({
            :creates => "#{ssldir}/certs/puppetmaster.example.com.pem",
            :command => "#{puppetcacmd} --generate puppetmaster.example.com --allow-dns-alt-names",
            :umask   => '0022',
            :require => ["Concat[#{conf_file}]", "Exec[puppet_server_config-create_ssl_dir]"],
          })
        end

        context 'with non-AIO packages', :if => (Puppet.version < '4.0' || facts[:osfamily] == 'FreeBSD') do
          it 'CA cert generation should notify the Apache service' do
            should contain_exec('puppet_server_config-generate_ca_cert').that_notifies('Service[httpd]')
          end
        end

        context 'with AIO packages', :if => (Puppet.version > '4.0' && facts[:osfamily] != 'FreeBSD') do
          it 'CA cert generation should notify the puppetserver service' do
            should contain_exec('puppet_server_config-generate_ca_cert').that_notifies('Service[puppetserver]')
          end
        end

        it 'should set up the ENC' do
          should contain_class('foreman::puppetmaster').with({
            :foreman_url    => "https://foo.example.com",
            :receive_facts  => true,
            :puppet_home    => puppetserver_vardir,
            :puppet_etcdir  => etcdir,
            # Since this is managed inside the foreman module it does not
            # make sense to test it here
            #:puppet_basedir => '/usr/lib/ruby/site_ruby/1.9/puppet',
            :timeout        => 60,
          })
        end

        it 'should set up the environments' do
          should contain_file(environments_dir).with({
            :ensure => 'directory',
            :owner => 'puppet',
            :group => nil,
            :mode => '0755',
          })
          should contain_file(sharedir).with_ensure('directory')
          should contain_file("#{codedir}/environments/common").with({
            :ensure => 'directory',
            :owner => 'puppet',
            :group => nil,
            :mode => '0755',
          })

          should contain_file("#{sharedir}/modules").with({
            :ensure => 'directory',
            :owner => 'puppet',
            :group => nil,
            :mode => '0755',
          })

          should contain_puppet__server__env('development')
          should contain_puppet__server__env('production')

        end

        it 'should configure puppet' do
          should contain_puppet__config__main("logdir").with({'value' => "#{logdir}"})
          should contain_puppet__config__main("rundir").with({'value' => "#{rundir}"})
          should contain_puppet__config__main("ssldir").with({'value' => "#{ssldir}"})
          should contain_puppet__config__main("privatekeydir").with({'value' => '$ssldir/private_keys { group = service }'})
          should contain_puppet__config__main("hostprivkey").with({'value' => '$privatekeydir/$certname.pem { mode = 640 }'})
          should contain_puppet__config__main("reports").with({'value' => 'foreman'})

          if Puppet.version >= '3.6'
            should contain_puppet__config__main("environmentpath").with({'value' => "#{codedir}/environments"})
            should contain_puppet__config__main("basemodulepath").with({
              'value'  => common_modules_path,
              'joiner' => ':'})
          end

          should contain_puppet__config__agent('classfile').with({'value' => '$statedir/classes.txt'})

          should contain_puppet__config__master('external_nodes').with({'value' => "#{etcdir}\/node.rb"})
          should contain_puppet__config__master('node_terminus').with({'value' => 'exec'})
          should contain_puppet__config__master('ca').with({'value' => 'true'})
          should contain_puppet__config__master('ssldir').with({'value' => "#{ssldir}"})
          should contain_puppet__config__master('parser').with({'value' => 'current'})
          should contain_puppet__config__master("autosign").with({'value' => "#{etcdir}\/autosign.conf \{ mode = 0664 \}"})

          should contain_concat(conf_file)

          should_not contain_puppet__config__master('storeconfigs')

          should contain_file("#{etcdir}/autosign.conf")

        end

        context 'on Puppet < 4.0.0', :if => (Puppet.version < '4.0.0') do
          it 'should set configtimeout' do
            should contain_puppet__config__agent('configtimeout').with({'value' => '120'})
          end
        end

        context 'on Puppet >= 4.0.0', :if => (Puppet.version >= '4.0.0') do
          it 'should not set configtimeout' do
            should_not contain_puppet__config__agent('configtimeout')
          end
        end

        it 'should not configure PuppetDB' do
          should_not contain_class('puppetdb')
          should_not contain_class('puppetdb::master::config')
        end
      end

      describe "when autosign => true" do
        let :pre_condition do
          "class {'puppet':
              server   => true,
              autosign => true,
           }"
        end

        it 'should contain puppet.conf [main] with autosign = true' do
          should contain_puppet__config__master('autosign').with({'value' => true})
        end
      end

      describe 'when autosign => /somedir/custom_autosign, autosign_mode => 664' do
        let :pre_condition do
          "class {'puppet':
              server        => true,
              autosign      => '/somedir/custom_autosign',
              autosign_mode => '664',
           }"
        end

        it 'should contain puppet.conf [main] with autosign = /somedir/custom_autosign { mode = 664 }' do
          should contain_puppet__config__master('autosign').with({'value' => "/somedir/custom_autosign { mode = 664 }"})
        end
      end

      describe "when autosign_entries is not set" do
        let :pre_condition do
          "class {'puppet':
              server  => true,
           }"
        end

        it 'should contain autosign.conf with out content set' do
           should contain_file("#{confdir}/autosign.conf")
           should_not contain_file("#{confdir}/autosign.conf").with_content(/# Managed by Puppet/)
           should_not contain_file("#{confdir}/autosign.conf").with_content(/foo.bar/)
        end
      end

      describe "when autosign_entries set to ['foo.bar']" do
        let :pre_condition do
          "class {'puppet':
              server           => true,
              autosign_entries => ['foo.bar'],
           }"
        end

        it 'should contain autosign.conf with content set' do
           should contain_file("#{confdir}/autosign.conf")
           should contain_file("#{confdir}/autosign.conf").with_content(/# Managed by Puppet/)
           should contain_file("#{confdir}/autosign.conf").with_content(/foo.bar/)
        end
      end

      describe "when autosign_content => set to foo.bar and and autosign_entries set to ['foo.bar']=> true" do
        let :pre_condition do
          "class {'puppet':
              server           => true,
              autosign_content => 'foo.bar',
              autosign_entries => ['foo.bar'],
           }"
        end

        it { should raise_error(Puppet::Error, /Cannot set both autosign_content and autosign_entries/) }
      end


      describe "when autosign => #{confdir}/custom_autosign.sh, autosign_mode => 664 and autosign_content set to 'foo.bar'" do
        let :pre_condition do
          "class {'puppet':
              server           => true,
              autosign         => '#{confdir}/custom_autosign.sh',
              autosign_mode    => '775',
              autosign_content => 'foo.bar',
           }"
        end

        it 'should contain puppet.conf [main] with autosign = /somedir/custom_autosign { mode = 775 }' do
          should contain_puppet__config__master('autosign').with({'value' => "#{confdir}/custom_autosign.sh { mode = 775 }"})
        end

        it 'should contain custom_autosign.sh with content set' do
           should contain_file("#{confdir}/custom_autosign.sh")
           should contain_file("#{confdir}/custom_autosign.sh").with_content(/foo.bar/)
        end
      end

      describe "when hiera_config => '$confdir/hiera.yaml'" do
        let :pre_condition do
          "class {'puppet':
              server        => true,
              hiera_config => '/etc/puppet/hiera/production/hiera.yaml',
           }"
        end

        it 'should contain puppet.conf [main] with non-default hiera_config' do
          should contain_puppet__config__main("hiera_config").with({'value' => '/etc/puppet/hiera/production/hiera.yaml'})
        end
      end

      describe 'without foreman' do
        let :pre_condition do
          "class {'puppet':
              server                => true,
              server_reports        => 'store',
              server_external_nodes => '',
           }"
        end

        it 'should contain an empty external_nodes' do
          should_not contain_puppet__config__master('external_nodes')
        end
      end

      describe 'without external_nodes' do
        let :pre_condition do
          "class {'puppet':
              server                => true,
              server_external_nodes => '',
           }"
        end

        it 'should not contain external_nodes' do
          should_not contain_puppet__config__master('external_nodes')
          should_not contain_puppet__config__master('node_terminus')
        end
      end


      describe 'with server_default_manifest => true and undef content' do
        let :pre_condition do
          'class { "::puppet":
              server_default_manifest => true,
              server => true
          }'
        end

        it 'should contain default_manifest setting in puppet.conf' do
          should contain_puppet__config__main('default_manifest').with({'value' => '/etc/puppet/manifests/default_manifest.pp'})
        end

        it 'should_not contain default manifest /etc/puppet/manifests/default_manifest.pp' do
          should_not contain_file('/etc/puppet/manifests/default_manifest.pp')
        end
      end

      describe 'with server_default_manifest => true and server_default_manifest_content => "include foo"' do
        let :pre_condition do
          'class { "::puppet":
              server_default_manifest => true,
              server_default_manifest_content => "include foo",
              server => true
          }'
        end

        it 'should contain default_manifest setting in puppet.conf' do
          should contain_puppet__config__main('default_manifest').with({'value' => '/etc/puppet/manifests/default_manifest.pp'})
        end

        it 'should contain default manifest /etc/puppet/manifests/default_manifest.pp' do
          should contain_file('/etc/puppet/manifests/default_manifest.pp').with_content(/include foo/)
        end
      end

      describe 'with git repo' do
        let :pre_condition do
          "class {'puppet':
              server          => true,
              server_git_repo => true,
           }"
        end

        it 'should set up the environments directory' do
          should contain_file(environments_dir).with({
            :ensure => 'directory',
            :owner  => 'puppet',
          })
        end

        it 'should create the git repo' do
          should contain_file(vardir).with({
            :ensure => 'directory',
            :owner  => 'puppet',
          })

          should contain_git__repo('puppet_repo').with({
            :bare    => true,
            :target  => "#{vardir}/puppet.git",
            :user    => 'puppet',
            :require => %r{File\[#{environments_dir}\]},
          })

          should contain_file("#{vardir}/puppet.git/hooks/post-receive").with({
            :owner   => 'puppet',
            :mode    => '0755',
            :require => %r{Git::Repo\[puppet_repo\]},
            :content => %r{BRANCH_MAP = \{[^a-zA-Z=>]\}},
          })
        end

        it { should_not contain_puppet__server__env('development') }
        it { should_not contain_puppet__server__env('production') }

        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet':
               server                        => true,
               server_git_repo               => true,
               server_directory_environments => true,
             }"
          end

          it 'should configure puppet.conf' do
            should_not contain_puppet__config__master('config_version')

            should contain_puppet__config__main('environmentpath').with({'value' => "#{environments_dir}"})
          end
        end

        context 'with config environments' do
          let :pre_condition do
            "class {'puppet':
               server                        => true,
               server_git_repo               => true,
               server_directory_environments => false,
             }"
          end

          it 'should configure puppet.conf' do
            should contain_puppet__config__master('manifest').with({'value' => "#{environments_dir}/\$environment/manifests/site.pp"})
            should contain_puppet__config__master('modulepath').with({'value' => "#{environments_dir}/\$environment/modules"})
            should contain_puppet__config__master('config_version').with({'value' => "git --git-dir #{environments_dir}/\$environment/.git describe --all --long"})
          end
        end
      end

      describe 'with dynamic environments' do
        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet':
               server                        => true,
               server_dynamic_environments   => true,
               server_directory_environments => true,
               server_environments_owner     => 'apache',
             }"
          end

          it 'should set up the environments directory' do
            should contain_file(environments_dir).with({
              :ensure => 'directory',
              :owner  => 'apache',
            })
          end

          it 'should configure puppet.conf' do
            should contain_puppet__config__main('environmentpath').with({'value' => "#{environments_dir}"})
            should contain_puppet__config__main('basemodulepath').with({'value' => common_modules_path})
          end

          it { should_not contain_puppet__server__env('development') }
          it { should_not contain_puppet__server__env('production') }
        end

        context 'with no common modules directory' do
          let :pre_condition do
            "class {'puppet':
               server                        => true,
               server_dynamic_environments   => true,
               server_directory_environments => true,
               server_environments_owner     => 'apache',
               server_common_modules_path    => '',
             }"
          end

          it 'should configure puppet.conf' do
            should_not contain_puppet__config__main('basemodulepath')
          end
        end

        context 'with config environments' do
          let :pre_condition do
            "class {'puppet':
               server                        => true,
               server_dynamic_environments   => true,
               server_directory_environments => false,
               server_environments_owner     => 'apache',
             }"
          end

          it 'should set up the environments directory' do
            should contain_file(environments_dir).with({
              :ensure => 'directory',
              :owner  => 'apache',
            })
          end

          it 'should configure puppet.conf' do
            should contain_puppet__config__master('manifest').with({'value' => "#{environments_dir}/\$environment/manifests/site.pp"})
            should contain_puppet__config__master('modulepath').with({'value' => "#{environments_dir}/\$environment/modules"})
          end

          it { should_not contain_puppet__server__env('development') }
          it { should_not contain_puppet__server__env('production') }
        end
      end

      describe 'with SSL path overrides' do
        let :pre_condition do
          "class {'puppet':
              server                  => true,
              server_foreman_ssl_ca   => '/etc/example/ca.pem',
              server_foreman_ssl_cert => '/etc/example/cert.pem',
              server_foreman_ssl_key  => '/etc/example/key.pem',
           }"
        end

        it 'should pass SSL parameters to the ENC' do
          should contain_class('foreman::puppetmaster').with({
            :ssl_ca   => '/etc/example/ca.pem',
            :ssl_cert => '/etc/example/cert.pem',
            :ssl_key  => '/etc/example/key.pem',
          })
        end
      end

      describe 'with a PuppetDB host set' do
        let :pre_condition do
          "class {'puppet':
              server                      => true,
              server_puppetdb_host        => 'mypuppetdb.example.com',
              server_storeconfigs_backend => 'puppetdb',
           }"
        end

        it 'should configure PuppetDB' do
          should compile.with_all_deps
          should contain_class('puppetdb::master::config').with({
            :puppetdb_server             => 'mypuppetdb.example.com',
            :puppetdb_port               => 8081,
            :puppetdb_soft_write_failure => false,
            :manage_storeconfigs         => false,
            :restart_puppet              => false,
          })
        end
      end

      describe 'with a puppet git branch map' do
        let :pre_condition do
          "class {'puppet':
              server                => true,
              server_git_repo       => true,
              server_git_branch_map => { 'a' => 'b', 'c' => 'd' }
           }"
        end

        it 'should add the branch map to the post receive hook' do
          should contain_file("#{vardir}/puppet.git/hooks/post-receive").
            with_content(/BRANCH_MAP = \{\n  "a" => "b",\n  "c" => "d",\n\}/)
        end
      end

      describe 'with additional settings' do
        let :pre_condition do
          "class {'puppet':
              server                      => true,
              server_additional_settings => {stringify_facts => true},
           }"
        end

        it 'should configure puppet.conf' do
          should contain_puppet__config__master('stringify_facts').with({'value' => true})
        end
      end

      describe 'directory environments default' do
        let :pre_condition do
          "class {'puppet':
             server => true,
           }"
        end

        context 'on old Puppet', :if => (Puppet.version < '3.6.0') do
          it 'should be disabled' do
            should_not contain_puppet__config__main('environmentpath')
          end
        end

        context 'on Puppet 3.6.0+', :if => (Puppet.version >= '3.6.0') do
          it 'should be enabled' do
            should contain_puppet__config__main('environmentpath').with({'value' => "#{environments_dir}"})
          end
        end
      end

      describe 'with server_parser => future' do
        let :pre_condition do
          "class {'puppet':
            server => true,
            server_parser => 'future',
          }"
        end

        it 'should configure future parser' do
          should contain_puppet__config__master('parser').with({'value' => "future"})
        end
      end

      describe 'with server_environment_timeout set' do
        let :pre_condition do
          "class {'puppet':
            server => true,
            server_environment_timeout => '10m',
          }"
        end

        it 'should configure environment_timeout accordingly' do
          should contain_puppet__config__master('environment_timeout').with({'value' => "10m"})
        end
      end

      describe 'with no ssldir managed for master' do
        let :pre_condition do
          "class {'puppet': server => true, server_ssl_dir_manage => false}"
        end

        it 'should not contain ssl_dir configuration setting in the master section' do
          should_not contain_puppet__config__master('ssl_dir')
        end
      end

      describe 'with ssl key management disabled for server' do
        let :pre_condition do
          "class {'puppet':
            server                => true,
            server_certname       => 'servercert',
            server_ssl_key_manage => false,
            server_ssl_dir        => '/etc/custom/puppetlabs/puppet/ssl'
          }"
        end

        it 'should not contain a default ssl key definition' do
          should_not contain_file('/etc/custom/puppetlabs/puppet/ssl/private_keys/servercert.pem')
        end
      end

      describe 'with nondefault CA settings' do
        context 'with server_ca => false' do
          let :pre_condition do
            "class {'puppet':
              server => true,
              server_ca => false,
            }"
          end

          it 'should create the ssl directory' do
            should contain_exec('puppet_server_config-create_ssl_dir')
          end

          it 'should not generate CA certificates' do
            should_not contain_exec('puppet_server_config-generate_ca_cert')
          end
        end
      end

      describe 'with server_implementation => "puppetserver"', :if => (Puppet.version >= '4.0.0') do
        let :pre_condition do
          "class {'puppet':
            server => true,
            server_implementation => 'puppetserver'
          }"
        end

        it 'should configure puppet.conf' do
          should contain_puppet__config__master("vardir").with_value(puppetserver_vardir)
          should contain_puppet__config__master("logdir").with_value(puppetserver_logdir)
          should contain_puppet__config__master("rundir").with_value(puppetserver_rundir)
        end
      end

      describe 'with server_ca_crl_sync => true' do
        context 'with server_ca => false and running "puppet apply"' do
          let :pre_condition do
            "class {'puppet':
              server             => true,
              server_ca_crl_sync => true,
              server_ca          => false,
              server_ssl_dir     => '/etc/custom/puppetlabs/puppet/ssl'
            }"
          end
          it 'should not sync the crl' do
            should_not contain_file('/etc/custom/puppetlabs/puppet/ssl/crl.pem')
          end
        end
        context 'with server_ca => false: running "puppet agent -t"' do
          let :pre_condition do
            "class {'puppet':
              server             => true,
              server_ca_crl_sync => true,
              server_ca          => false,
              server_ssl_dir     => '/etc/custom/puppetlabs/puppet/ssl'
            }"
          end
          let(:facts) do
            facts.merge({:servername => 'myserver' })
          end

          it 'should sync the crl from the ca' do
            should contain_file('/etc/custom/puppetlabs/puppet/ssl/crl.pem').
               with_content("This is my CRL File")
          end
        end
        context 'with server_ca => true: running "puppet agent -t"' do
          let :pre_condition do
            "class {'puppet':
              server             => true,
              server_ca_crl_sync => true,
              server_ca          => true,
              server_ssl_dir     => '/etc/custom/puppetlabs/puppet/ssl'
            }"
          end
          let(:facts) do
            facts.merge({:servername => 'myserver' })
          end

          it 'should not sync the crl' do
            should_not contain_file('/etc/custom/puppetlabs/puppet/ssl/crl.pem')
          end
        end
      end

      describe 'allow crl checking' do
        context 'as ca' do
          let :pre_condition do
            "class {'puppet':
              server                  => true,
              server_implementation   => 'puppetserver',
              server_ca               => true,
              server_puppetserver_dir => '/etc/custom/puppetserver',
              server_jruby_gem_home   => '/opt/puppetlabs/server/data/puppetserver/jruby-gems'
            }"
          end
          it 'should use the ca_crl.pem file' do
             should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
               with_content(/ssl-crl-path: #{ssldir}\/ca\/ca_crl.pem/)
          end
        end
        context 'as non-ca with default' do
          let :pre_condition do
            "class {'puppet':
              server                  => true,
              server_implementation   => 'puppetserver',
              server_ca               => false,
              server_puppetserver_dir => '/etc/custom/puppetserver',
              server_jruby_gem_home   => '/opt/puppetlabs/server/data/puppetserver/jruby-gems'
            }"
          end
          it 'should use the ca_crl.pem file' do
             should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
               without_content(/ssl-crl-path: #{ssldir}\/crl.pem/)
          end
        end
        context 'as non-ca with default' do
          let :pre_condition do
            "class {'puppet':
              server                  => true,
              server_implementation   => 'puppetserver',
              server_ca               => false,
              server_crl_enable       => true,
              server_puppetserver_dir => '/etc/custom/puppetserver',
              server_jruby_gem_home   => '/opt/puppetlabs/server/data/puppetserver/jruby-gems'
            }"
          end
          it 'should use the ca_crl.pem file' do
             should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
               with_content(/ssl-crl-path: #{ssldir}\/crl.pem/)
          end
        end
      end

      describe 'with ssl_protocols overwritten' do
        let :pre_condition do
          "class {'puppet':
              server                    => true,
              server_implementation     => 'puppetserver',
              server_ca                 => true,
              server_puppetserver_dir   => '/etc/custom/puppetserver',
              server_ssl_protocols      => ['TLSv1.1', 'TLSv1.2'],
           }"
        end

        it 'should set the ssl protocols' do
          should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
            with_content(/ssl-protocols:.*TLSv1.1.*TLSv1.2.*/)
        end
      end

      describe 'with cipher-suites overwritten' do
        let :pre_condition do
          "class {'puppet':
              server                    => true,
              server_implementation     => 'puppetserver',
              server_ca                 => true,
              server_puppetserver_dir   => '/etc/custom/puppetserver',
              server_cipher_suites      => ['TLS_RSA_WITH_AES_256_CBC_SHA256', 'TLS_RSA_WITH_AES_256_CBC_SHA'],
           }"
        end

        it 'should set the cipher suite' do
          should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
            with_content(/cipher-suites:.*TLS_RSA_WITH_AES_256_CBC_SHA256.*TLS_RSA_WITH_AES_256_CBC_SHA.*/)
        end
      end

      describe 'with ssl_chain_filepath overwritten' do
	let :pre_condition do
          "class {'puppet':
              server                      => true,
              server_implementation       => 'puppetserver',
              server_ca                   => true,
              server_puppetserver_dir     => '/etc/custom/puppetserver',
              server_jruby_gem_home       => '/opt/puppetlabs/server/data/puppetserver/jruby-gems',
              server_ssl_chain_filepath   => '/etc/example/certchain.pem',
           }"
        end
        it 'should use the server_ssl_chain_filepath file' do
           should contain_file('/etc/custom/puppetserver/conf.d/webserver.conf').
             with_content(/ssl-cert-chain: \/etc\/example\/certchain.pem/)
        end
      end
    end
  end
end
