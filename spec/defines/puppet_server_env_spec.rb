require 'spec_helper'

describe 'puppet::server::env' do
  on_os_under_test.each do |os, facts|
    next if facts[:osfamily] == 'windows'
    next if facts[:osfamily] == 'Archlinux'
    context "on #{os}" do
      if Puppet.version < '4.0'
        codedir = '/etc/puppet'
        confdir = '/etc/puppet'
        logdir  = '/var/log/puppet'
        rundir  = '/var/run/puppet'
        ssldir  = '/var/lib/puppet/ssl'
        vardir  = '/var/lib/puppet'
        sharedir = '/usr/share/puppet'
        additional_facts = {}
        common_modules_path = ["#{codedir}/environments/common","#{codedir}/modules","#{sharedir}/modules"]
      else
        codedir = '/etc/puppetlabs/code'
        confdir = '/etc/puppetlabs/puppet'
        logdir  = '/var/log/puppetlabs/puppet'
        rundir  = '/var/run/puppetlabs'
        ssldir  = '/etc/puppetlabs/puppet/ssl'
        vardir  = '/opt/puppetlabs/puppet/cache'
        sharedir = '/opt/puppetlabs/puppet'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
        common_modules_path = ["#{codedir}/environments/common","#{codedir}/modules","#{sharedir}/modules","/usr/share/puppet/modules"]
      end

      if facts[:osfamily] == 'FreeBSD'
        codedir = '/usr/local/etc/puppet'
        confdir = '/usr/local/etc/puppet'
        logdir  = '/var/log/puppet'
        rundir  = '/var/run/puppet'
        ssldir  = '/var/puppet/ssl'
        vardir  = '/var/puppet'
        sharedir = '/usr/local/share/puppet'
        additional_facts = {}
      end

      let(:facts) { facts.merge(additional_facts) }

      let(:title) { 'foo' }

      context 'with no custom parameters' do
        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => true}"
          end

          it 'should only deploy directories' do
            should contain_file("#{codedir}/environments").with({
              :ensure => 'directory',
              :owner => 'puppet',
              :group => nil,
              :mode => '0755',
            })

            should contain_file("#{codedir}/environments/foo").with({
              :ensure => 'directory',
              :owner => 'puppet',
              :group => nil,
              :mode => '0755',
            })

            should contain_file("#{codedir}/environments/foo/manifests").with({
              :ensure => 'directory',
              :owner => 'puppet',
              :group => nil,
              :mode => '0755',
            })

            should contain_file("#{codedir}/environments/foo/modules").with({
              :ensure => 'directory',
              :owner => 'puppet',
              :group => nil,
              :mode => '0755',
            })

            should_not contain_file("#{codedir}/environments/foo/environment.conf")
            should_not contain_concat__fragment('puppet.conf_foo')
          end
        end

        context 'with config environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => false}"
          end

          it 'should add an env section' do
            should contain_file("#{codedir}/environments/foo").with({
              :ensure => 'directory',
              :owner => 'puppet',
              :group => nil,
              :mode => '0755',
            })

            should contain_file("#{codedir}/environments/foo/modules").with({
              :ensure => 'directory',
              :owner => 'puppet',
              :group => nil,
              :mode => '0755',
            })

            should_not contain_puppet__config__environment('foo_manifest')
            should_not contain_puppet__config__environment('foo_manifestdir')
            should_not contain_puppet__config__environment('foo_templatedir')
            should_not contain_puppet__config__environment('foo_config_version')
            should contain_puppet__config__environment('foo_modulepath').with({
              'key'    => 'modulepath',
              'value'  => ["#{codedir}/environments/foo/modules", common_modules_path],
              'joiner' => ':',
              })

            should_not contain_file("#{codedir}/environments/foo/environment.conf")
          end
        end
      end

      context 'with server_config_version' do
        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => true, server_config_version => 'bar'}"
          end

          it 'should set config_version in environment.conf' do
            should contain_file("#{codedir}/environments/foo/environment.conf").
              with_content(%r{\Aconfig_version\s+= bar\n\z}).
              with({}) # So we can use a trailing dot on each with_content line
          end
        end

        context 'with config environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => false, server_config_version => 'bar'}"
          end

          it 'should add config_version to an env section' do
            should_not contain_puppet__config__environment('foo_manifest')
            should_not contain_puppet__config__environment('foo_manifestdir')
            should_not contain_puppet__config__environment('foo_templatedir')
            should contain_puppet__config__environment('foo_modulepath').with({
              'key'    => 'modulepath',
              'value'  => ["#{codedir}/environments/foo/modules", common_modules_path],
              'joiner' => ':',
              })
            should contain_puppet__config__environment('foo_config_version').with({
              'key'   => 'config_version',
              'value' => 'bar',
              })
          end
        end
      end

      context 'with config_version' do
        let :params do
          {
            :config_version => 'bar',
          }
        end

        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => true}"
          end

          it 'should set config_version in environment.conf' do
            should contain_file("#{codedir}/environments/foo/environment.conf").
              with_content(%r{\Aconfig_version\s+= bar\n\z}).
              with({}) # So we can use a trailing dot on each with_content line
          end
        end

        context 'with config environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => false}"
          end

          it 'should add config_version to an env section' do
            should_not contain_puppet__config__environment('foo_manifest')
            should_not contain_puppet__config__environment('foo_manifestdir')
            should_not contain_puppet__config__environment('foo_templatedir')
            should contain_puppet__config__environment('foo_modulepath').with({
              'key'    => 'modulepath',
              'value'  => ["#{codedir}/environments/foo/modules", common_modules_path],
              'joiner' => ':',
              })
            should contain_puppet__config__environment('foo_config_version').with({
              'key'   => 'config_version',
              'value' => 'bar',
              })
          end
        end

        context 'with directory environments link' do
          let :pre_condition do
            "class {'puppet': server => true, server_envs_target => '/foo'}"
          end

          it 'should produce a symbolic link "environments" in codedir' do
            should contain_file("#{codedir}/environments").
              with_target('/foo').
              with_ensure('link').
              with({}) # So we can use a trailing dot on each with_content line
          end
        end
      end

      context 'with modulepath' do
        let :params do
          {
            :modulepath => ['/etc/puppet/example/modules', '/etc/puppet/vendor/modules'],
          }
        end

        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => true}"
          end

          it 'should set modulepath in environment.conf' do
            should contain_file("#{codedir}/environments/foo/environment.conf").
              with_content(%r{\Amodulepath\s+= /etc/puppet/example/modules:/etc/puppet/vendor/modules\n}).
              with({}) # So we can use a trailing dot on each with_content line
          end
        end
      end

      context 'with undef modulepath' do
        let :params do
          {
            :modulepath => Undef.new,
          }
        end

        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => true}"
          end

          it { should_not contain_file("#{codedir}/environments/foo/environment.conf") }
        end
      end

      context 'with custom basedir' do
        basedir = "#{codedir}/baz_environments"
        let :params do
          {
            :basedir => basedir,
          }
        end

        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => true}"
          end

          it { should_not contain_file("#{codedir}/environments/foo/environment.conf") }
          it { should_not contain_file("#{basedir}/foo/environment.conf") }
        end

        context 'with config environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => false}"
          end

          it 'should add modulepath with custom basedir to an env section' do
            should_not contain_puppet__config__environment('foo_manifest')
            should_not contain_puppet__config__environment('foo_manifestdir')
            should_not contain_puppet__config__environment('foo_templatedir')
            should_not contain_puppet__config__environment('foo_config_version')
            should contain_puppet__config__environment('foo_modulepath').with({
              'key'    => 'modulepath',
              'value'  => ["#{basedir}/foo/modules", common_modules_path],
              'joiner' => ':',
              })
          end
        end
      end

      context 'with manifest' do
        let :params do
          {
            :manifest => 'manifests/local.pp',
          }
        end

        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => true}"
          end

          it 'should set manifest in environment.conf' do
            should contain_file("#{codedir}/environments/foo/environment.conf").
              with_content(%r{\Amanifest\s+= manifests/local.pp\n\z}).
              with({}) # So we can use a trailing dot on each with_content line
          end
        end
      end

      context 'with environment_timeout' do
        let :params do
          {
            :environment_timeout => 'unlimited',
          }
        end

        context 'with directory environments' do
          let :pre_condition do
            "class {'puppet': server => true, server_directory_environments => true}"
          end

          it 'should set environment_timeout in environment.conf' do
            should contain_file("#{codedir}/environments/foo/environment.conf").
              with_content(%r{\Aenvironment_timeout\s+= unlimited\n\z}).
              with({}) # So we can use a trailing dot on each with_content line
          end
        end
      end

    end
  end
end
