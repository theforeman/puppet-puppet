require 'spec_helper'

describe 'puppet::server::config' do
  let :default_facts do on_supported_os['centos-6-x86_64'].merge({
    :clientcert             => 'puppetmaster.example.com',
    :concat_basedir         => '/nonexistant',
    :fqdn                   => 'puppetmaster.example.com',
    :rubyversion            => '1.9.3',
    :puppetversion          => Puppet.version,
  }) end

  if Puppet.version < '4.0'
    codedir          = '/etc/puppet'
    conf_file        = '/etc/puppet/puppet.conf'
    environments_dir = '/etc/puppet/environments'
    logdir           = '/var/log/puppet'
    rundir           = '/var/run/puppet'
    vardir           = '/var/lib/puppet'
    ssldir           = '/var/lib/puppet/ssl'
    sharedir         = '/usr/share/puppet'
    nodepath         = '\/etc\/puppet\/node.rb'
    additional_facts = {}
  else
    codedir          = '/etc/puppetlabs/code'
    conf_file        = '/etc/puppetlabs/puppet/puppet.conf'
    environments_dir = '/etc/puppetlabs/code/environments'
    logdir           = '/var/log/puppetlabs/puppet'
    rundir           = '/var/run/puppetlabs'
    vardir           = '/opt/puppetlabs/puppet/cache'
    ssldir           = '/etc/puppetlabs/puppet/ssl'
    sharedir         = '/opt/puppetlabs/puppet'
    nodepath         = '\/etc\/puppetlabs\/puppet\/node.rb'
    additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
  end

  let(:facts) { default_facts.merge(additional_facts) }

  describe 'with no custom parameters' do
    let :pre_condition do
      "class {'puppet': server => true}"
    end

    it 'should set up SSL permissions' do
      should contain_file("#{ssldir}/private_keys").with({
        :group => 'puppet',
        :mode  => '0750',
      })

      should contain_file("#{ssldir}/private_keys/#{facts[:fqdn]}.pem").with({
        :group => 'puppet',
        :mode  => '0640',
      })

      should contain_exec('puppet_server_config-create_ssl_dir').with({
        :creates => ssldir,
        :command => "/bin/mkdir -p #{ssldir}",
      })

      puppetcacmd = Puppet.version >= '4' ? '/opt/puppetlabs/bin/puppet cert' : ( Puppet.version >= '3' ? '/usr/bin/puppet cert' : '/usr/sbin/puppetca' )
      should contain_exec('puppet_server_config-generate_ca_cert').with({
        :creates => "#{ssldir}/certs/#{facts[:fqdn]}.pem",
        :command => "#{puppetcacmd} --generate #{facts[:fqdn]}",
        :require => ["Concat[#{conf_file}]", "Exec[puppet_server_config-create_ssl_dir]"],
      }).that_notifies('Service[httpd]')
    end

    context 'on Puppet 3.4+', :if => (Puppet.version >= '3.4.0') do
      it 'should set sane umask on execs' do
        should contain_exec('puppet_server_config-create_ssl_dir').with_umask('0022')
        should contain_exec('puppet_server_config-generate_ca_cert').with_umask('0022')
      end
    end

    it 'should set up the ENC' do
      should contain_class('foreman::puppetmaster').with({
        :foreman_url    => "https://#{facts[:fqdn]}",
        :receive_facts  => true,
        :puppet_home    => vardir,
        :puppet_basedir => '/usr/lib/ruby/site_ruby/1.9/puppet',
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

      should contain_file("#{codedir}/manifests/site.pp").with({
        :ensure  => 'file',
        :replace => false,
        :content => "# site.pp must exist (puppet #15106, foreman #1708)\n",
      })

      should contain_puppet__server__env('development')
      should contain_puppet__server__env('production')

    end

    it 'should configure puppet' do
      should contain_concat__fragment('puppet.conf+10-main').
        with_content(/^\s+logdir\s+= #{logdir}$/).
        with_content(/^\s+rundir\s+= #{rundir}$/).
        with_content(/^\s+ssldir\s+= #{ssldir}$/).
        with_content(/^\s+privatekeydir\s+= \$ssldir\/private_keys { group = service }$/).
        with_content(/^\s+hostprivkey\s+= \$privatekeydir\/\$certname.pem { mode = 640 }$/).
        with_content(/^\s+autosign\s+= \$confdir\/autosign.conf { mode = 664 }$/).
        with({}) # So we can use a trailing dot on each with_content line

      should contain_concat__fragment('puppet.conf+20-agent').
        with_content(/^\s+classfile\s+= \$statedir\/classes.txt/).
        with({}) # So we can use a trailing dot on each with_content line

      should contain_concat__fragment('puppet.conf+30-master').
        with_content(/^\s+reports\s+= foreman$/).
        with_content(/^\s+external_nodes\s+= #{nodepath}$/).
        with_content(/^\s+node_terminus\s+= exec$/).
        with_content(/^\s+ca\s+= true$/).
        with_content(/^\s+ssldir\s+= #{ssldir}$/).
        with_content(/^\s+parser\s+=\s+current$/).
        with({}) # So we can use a trailing dot on each with_content line

      should contain_concat(conf_file)

      should_not contain_file('/etc/puppet/puppet.conf').with_content(/storeconfigs/)
    end

    context 'on Puppet < 4.0.0', :if => (Puppet.version < '4.0.0') do
      it 'should set configtimeout' do
        should contain_concat__fragment('puppet.conf+20-agent').
          with_content(/^\s+configtimeout\s+= 120$/)
      end
    end

    context 'on Puppet >= 4.0.0', :if => (Puppet.version >= '4.0.0') do
      it 'should not set configtimeout' do
        should contain_concat__fragment('puppet.conf+20-agent').
          without_content(/^\s+configtimeout\s+= 120$/)
      end
    end

    it 'should not configure PuppetDB' do
      should_not contain_class('puppetdb')
      should_not contain_class('puppetdb::master::config')
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

    it 'should store reports' do
      should contain_concat__fragment('puppet.conf+30-master').with_content(/^\s+reports\s+= store$/)
    end

    it 'should contain an empty external_nodes' do
      should contain_concat__fragment('puppet.conf+30-master').with_content(/^\s+external_nodes\s+=\s+$/)
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
      should contain_concat__fragment('puppet.conf+30-master').
        with_content(/^\s+external_nodes\s+= $/).
        with_content(/^\s+node_terminus\s+= plain$/).
        with({})
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
        should_not contain_concat__fragment('puppet.conf+30-master').with_content(%r{^\s+config_version\s+=$})

        should contain_concat__fragment('puppet.conf+10-main').
          with_content(%r{^\s+environmentpath\s+= #{environments_dir}$})
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
        should contain_concat__fragment('puppet.conf+30-master').
          with_content(%r{^\s+manifest\s+= #{environments_dir}/\$environment/manifests/site.pp\n\s+modulepath\s+= #{environments_dir}/\$environment/modules$}).
          with_content(%r{^\s+config_version\s+= git --git-dir #{environments_dir}/\$environment/.git describe --all --long$})
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
        should contain_concat__fragment('puppet.conf+10-main').
          with_content(%r{^\s+environmentpath\s+= #{environments_dir}\n\s+basemodulepath\s+= #{environments_dir}/common:#{codedir}/modules:#{sharedir}/modules$})
      end

      it { should_not contain_puppet__server__env('development') }
      it { should_not contain_puppet__server__env('production') }
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
        should contain_concat__fragment('puppet.conf+30-master').
          with_content(%r{^\s+manifest\s+= #{environments_dir}/\$environment/manifests/site.pp\n\s+modulepath\s+= #{environments_dir}/\$environment/modules$})
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
        with_content(/BRANCH_MAP = {\n  "a" => "b",\n  "c" => "d",\n}/)
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
      should contain_concat__fragment('puppet.conf+30-master').
        with_content(/^\s+stringify_facts\s+= true$/).
        with({}) # So we can use a trailing dot on each with_content line
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
        should contain_concat__fragment('puppet.conf+30-master').
          without_content(%r{^\s+environmentpath\s+=$})
      end
    end

    context 'on Puppet 3.6.0+', :if => (Puppet.version >= '3.6.0') do
      it 'should be enabled' do
        should contain_concat__fragment('puppet.conf+10-main').
          with_content(%r{^\s+environmentpath\s+= #{environments_dir}$})
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
      should contain_concat__fragment('puppet.conf+30-master').
        with_content(/^\s+parser\s+=\s+future$/)
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
      should contain_concat__fragment('puppet.conf+30-master').
        with_content(/^\s+environment_timeout\s+=\s+10m$/)
    end
  end

  describe 'with no ssldir managed for master' do
    let :pre_condition do
      "class {'puppet': server => true, server_ssl_dir_manage => false}"
    end

    it 'should not contain ssl_dir configuration setting in the master section' do
      should_not contain_concat__fragment('puppet.conf+30-master').
        with_content(/^\s+ssl_dir\s+=\s+.*$/)
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

end
