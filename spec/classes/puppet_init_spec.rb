require 'spec_helper'

describe 'puppet' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      case facts[:osfamily]
      when 'FreeBSD'
        puppet_major = facts[:puppetversion].to_i

        puppet_concat    = '/usr/local/etc/puppet/puppet.conf'
        puppet_directory = '/usr/local/etc/puppet'
        puppet_package   = "puppet#{puppet_major}"
      when 'windows'
        puppet_concat    = 'C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
        puppet_directory = 'C:/ProgramData/PuppetLabs/puppet/etc'
        puppet_package   = 'puppet-agent'
      when 'Archlinux'
        puppet_concat    = '/etc/puppetlabs/puppet/puppet.conf'
        puppet_directory = '/etc/puppetlabs/puppet'
        puppet_package   = 'puppet'
      else
        puppet_concat    = '/etc/puppetlabs/puppet/puppet.conf'
        puppet_directory = '/etc/puppetlabs/puppet'
        puppet_package   = 'puppet-agent'
      end

      let :facts do
        facts
      end

      describe 'with no custom parameters' do
        it { is_expected.to compile.with_all_deps unless facts[:osfamily] == 'windows' }
        it { should contain_class('puppet::agent') }
        it { should contain_class('puppet::config') }
        it { should_not contain_class('puppet::server') }
        it { should contain_file(puppet_directory).with_ensure('directory') }
        it { should contain_concat(puppet_concat) }
        it { should contain_package(puppet_package)
          .with_ensure('present')
          .with_install_options(nil)
        }
      end

      describe 'with server => true', :unless => unsupported_puppetmaster_osfamily(facts[:osfamily]) do
        let :params do {
          :server => true,
        } end

        it { is_expected.to compile.with_all_deps }
        it { should contain_class('puppet::server') }
        it { should contain_class('puppet::agent::service').that_requires('Class[puppet::server]') }
      end

      describe 'with empty ca_server' do
        let :params do {
          :ca_server => '',
        } end

        it { should_not contain_puppet__config__main('ca_server') }
      end

      describe 'with ca_server' do
        let :params do {
          :ca_server => 'ca.example.org',
        } end

        it { should contain_puppet__config__main('ca_server').with_value('ca.example.org') }
      end

      describe 'with undef ca_port' do
        let :params do {
          :ca_port => :undef,
        } end

        it { should_not contain_puppet__config__main('ca_port') }
      end

      describe 'with ca_port' do
        let :params do {
          :ca_port => 8140,
        } end

        it { should contain_puppet__config__main('ca_port').with_value(8140) }
      end

      # compilation is broken due to paths
      context 'on non-windows', unless: facts[:osfamily] == 'windows' do
        describe 'with package_source => Httpurl' do
          let :params do {
            :package_source => 'https://example.com:123/test'
          } end

          it { is_expected.to compile }
        end

        describe 'with package_source => Unixpath' do
          let :params do {
            :package_source => '/test/folder/path/source.rpm'
          } end

          it { is_expected.to compile }
        end

        describe 'with package_source => Windowspath' do
          let :params do {
            :package_source => 'C:\test\folder\path\source.exe'
          } end

          it { is_expected.to compile }
        end

        describe 'with package_source => foo' do
          let :params do {
            :package_source => 'foo'
          } end

          it { is_expected.not_to compile }
        end
      end
    end
  end
end
