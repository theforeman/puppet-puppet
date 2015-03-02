require 'spec_helper'

describe 'puppet::server::config' do
  let :default_facts do {
    :clientcert             => 'puppetmaster.example.com',
    :concat_basedir         => '/nonexistant',
    :fqdn                   => 'puppetmaster.example.com',
    :rubyversion            => '1.9.3',
    :operatingsystemrelease => '6.5',
    :osfamily               => 'RedHat',
  } end
  let(:facts) { default_facts }

  describe 'with no custom parameters' do
    let :pre_condition do
      "class {'puppet': server => true}"
    end

    it 'should set up SSL permissions' do
      should contain_file('/var/lib/puppet/ssl/private_keys').with({
        :group => 'puppet',
        :mode  => '0750',
      })

      should contain_file("/var/lib/puppet/ssl/private_keys/#{facts[:fqdn]}.pem").with({
        :group => 'puppet',
        :mode  => '0640',
      })

      should contain_exec('puppet_server_config-create_ssl_dir').with({
        :creates => '/var/lib/puppet/ssl',
        :command => '/bin/mkdir -p /var/lib/puppet/ssl',
        :before  => /Exec\[puppet_server_config-generate_ca_cert\]/
      })

      should contain_exec('puppet_server_config-generate_ca_cert').with({
        :creates => "/var/lib/puppet/ssl/certs/#{facts[:fqdn]}.pem",
        :command => "/usr/sbin/puppetca --generate #{facts[:fqdn]}",
        :require => /File\[\/etc\/puppet\/puppet\.conf\]/,
      }).that_notifies('Service[httpd]')
    end

    it 'should set up the ENC' do
      should contain_class('foreman::puppetmaster').with({
        :foreman_url    => "https://#{facts[:fqdn]}",
        :receive_facts  => true,
        :puppet_home    => '/var/lib/puppet',
        :puppet_basedir => '/usr/lib/ruby/site_ruby/1.9/puppet',
        :timeout        => 60,
      })
    end

    it 'should set up the environments' do
      should contain_file('/etc/puppet/environments').with_ensure('directory')
      should contain_file('/usr/share/puppet').with_ensure('directory')
      should contain_file('/etc/puppet/environments/common').with_ensure('directory')
      should contain_file('/usr/share/puppet/modules').with_ensure('directory')

      should contain_file('/etc/puppet/manifests/site.pp').with({
        :ensure  => 'file',
        :replace => false,
        :content => "# site.pp must exist (puppet #15106, foreman #1708)\n",
      })

      should contain_puppet__server__env('development')
      should contain_puppet__server__env('production')
    end

    it 'should configure puppet' do
      should contain_concat_build('puppet.conf')

      should contain_concat_fragment('puppet.conf+10-main').
        with_content(/^\s+logdir\s+= \/var\/log\/puppet$/).
        with_content(/^\s+rundir\s+= \/var\/run\/puppet$/).
        with_content(/^\s+ssldir\s+= \$vardir\/ssl$/).
        with_content(/^\s+privatekeydir\s+= \$ssldir\/private_keys { group = service }$/).
        with_content(/^\s+hostprivkey\s+= \$privatekeydir\/\$certname.pem { mode = 640 }$/).
        with_content(/^\s+autosign\s+= \$confdir\/autosign.conf { mode = 664 }$/).
        with({}) # So we can use a trailing dot on each with_content line

      should contain_concat_fragment('puppet.conf+20-agent').
        with_content(/^\s+configtimeout\s+= 120$/).
        with_content(/^\s+classfile\s+= \$vardir\/classes.txt/).
        with({}) # So we can use a trailing dot on each with_content line

      should contain_concat_fragment('puppet.conf+30-master').
        with_content(/^\s+reports\s+= foreman$/).
        with_content(/^\s+external_nodes\s+= \/etc\/puppet\/node.rb$/).
        with_content(/^\s+node_terminus\s+= exec$/).
        with_content(/^\s+ca\s+= true$/).
        with_content(/^\s+ssldir\s+= \/var\/lib\/puppet\/ssl$/).
        with_content(/^\s+parser\s+=\s+current$/).
        with({}) # So we can use a trailing dot on each with_content line

      should contain_file('/etc/puppet/puppet.conf')

      should_not contain_file('/etc/puppet/puppet.conf').with_content(/storeconfigs/)
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
      should contain_concat_fragment('puppet.conf+30-master').with_content(/^\s+reports\s+= store$/)
    end

    it 'should contain an empty external_nodes' do
      should contain_concat_fragment('puppet.conf+30-master').with_content(/^\s+external_nodes\s+=\s+$/)
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
      should contain_concat_fragment('puppet.conf+30-master').
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
      should contain_file('/etc/puppet/environments').with({
        :ensure => 'directory',
        :owner  => 'puppet',
      })
    end

    it 'should create the git repo' do
      should contain_file('/var/lib/puppet').with({
        :ensure => 'directory',
        :owner  => 'puppet',
      })

      should contain_git__repo('puppet_repo').with({
        :bare    => true,
        :target  => '/var/lib/puppet/puppet.git',
        :user    => 'puppet',
        :require => %r{File\[/etc/puppet/environments\]},
      })

      should contain_file('/var/lib/puppet/puppet.git/hooks/post-receive').with({
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
        should_not contain_concat_fragment('puppet.conf+30-master').with_content(%r{^\s+config_version\s+=$})

        should contain_concat_fragment('puppet.conf+10-main').
          with_content(%r{^\s+environmentpath\s+= /etc/puppet/environments$})
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
        should contain_concat_fragment('puppet.conf+30-master').
          with_content(%r{^\s+manifest\s+= /etc/puppet/environments/\$environment/manifests/site.pp\n\s+modulepath\s+= /etc/puppet/environments/\$environment/modules$}).
          with_content(%r{^\s+config_version\s+= git --git-dir /etc/puppet/environments/\$environment/.git describe --all --long$})
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
        should contain_file('/etc/puppet/environments').with({
          :ensure => 'directory',
          :owner  => 'apache',
        })
      end

      it 'should configure puppet.conf' do
        should contain_concat_fragment('puppet.conf+10-main').
          with_content(%r{^\s+environmentpath\s+= /etc/puppet/environments\n\s+basemodulepath\s+= /etc/puppet/environments/common:/etc/puppet/modules:/usr/share/puppet/modules$})
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
        should contain_file('/etc/puppet/environments').with({
          :ensure => 'directory',
          :owner  => 'apache',
        })
      end

      it 'should configure puppet.conf' do
        should contain_concat_fragment('puppet.conf+30-master').
          with_content(%r{^\s+manifest\s+= /etc/puppet/environments/\$environment/manifests/site.pp\n\s+modulepath\s+= /etc/puppet/environments/\$environment/modules$})
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
      should contain_file('/var/lib/puppet/puppet.git/hooks/post-receive').
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
      should contain_concat_fragment('puppet.conf+30-master').
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

    context 'on old Puppet' do
      let(:facts) { default_facts.merge(:puppetversion => '3.5.3') }
      it 'should be disabled' do
        should contain_concat_fragment('puppet.conf+30-master').
          without_content(%r{^\s+environmentpath\s+=$})
      end
    end

    context 'on Puppet 3.6.0+' do
      let(:facts) { default_facts.merge(:puppetversion => '3.6.0') }
      it 'should be enabled' do
        should contain_concat_fragment('puppet.conf+10-main').
          with_content(%r{^\s+environmentpath\s+= /etc/puppet/environments$})
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
      should contain_concat_fragment('puppet.conf+30-master').
        with_content(/^\s+parser\s+=\s+future$/)
    end
  end
end
