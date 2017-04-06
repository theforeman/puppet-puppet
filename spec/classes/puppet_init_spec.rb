require 'spec_helper'

describe 'puppet' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      if Puppet.version < '4.0'
        puppet_concat    = '/etc/puppet/puppet.conf'
        puppet_directory = '/etc/puppet'
        puppet_package   = 'puppet'
        additional_facts = {}
        case facts[:osfamily]
        when 'FreeBSD'
          puppet_concat    = '/usr/local/etc/puppet/puppet.conf'
          puppet_directory = '/usr/local/etc/puppet'
          puppet_package   = 'puppet38'
        when 'windows'
          puppet_concat    = 'C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
          puppet_directory = 'C:/ProgramData/PuppetLabs/puppet/etc'
          puppet_package   = 'puppet'
        end
      else
        puppet_concat    = '/etc/puppetlabs/puppet/puppet.conf'
        puppet_directory = '/etc/puppetlabs/puppet'
        puppet_package   = 'puppet-agent'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
        case facts[:osfamily]
        when 'FreeBSD'
          puppet_concat    = '/usr/local/etc/puppet/puppet.conf'
          puppet_directory = '/usr/local/etc/puppet'
          puppet_package   = 'puppet4'
          additional_facts = {}
        when 'windows'
          puppet_concat    = 'C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
          puppet_directory = 'C:/ProgramData/PuppetLabs/puppet/etc'
          puppet_package   = 'puppet-agent'
          additional_facts = {}
        end
      end

      let :facts do
        facts.merge(additional_facts)
      end

      describe 'with no custom parameters' do
        it { is_expected.to compile.with_all_deps unless facts[:osfamily] == 'windows' }
        it { should contain_class('puppet::agent') }
        it { should contain_class('puppet::config') }
        it { should_not contain_class('puppet::server') }
        if Puppet.version < '4.0'
          it { should contain_file(puppet_directory).with_ensure('directory') }
          it { should contain_concat(puppet_concat) }
          it { should contain_package(puppet_package).with_ensure('present') }
        else
          it { should contain_file(puppet_directory).with_ensure('directory') }
          it { should contain_concat(puppet_concat) }
          it { should contain_package(puppet_package).with_ensure('present') }
        end
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

        it {
          should_not contain_puppet__config__main('ca_server')
        }
      end

      describe 'with ca_server' do
        let :params do {
          :ca_server => 'ca.example.org',
        } end

        it {
          should contain_puppet__config__main('ca_server').with({'value' => 'ca.example.org'})
        }
      end

      describe 'with undef ca_port' do
        let :params do {
          :ca_port => :undef,
        } end

        it {
          should_not contain_puppet__config__main('ca_port')
        }
      end

      describe 'with ca_port' do
        let :params do {
          :ca_port => 8140,
        } end

        it {
          should contain_puppet__config__main('ca_port').with({'value' => '8140'})
        }
      end

      describe 'with ca_port' do
        let :params do {
          :ca_port => 8140,
        } end

        it {
          should contain_puppet__config__main('ca_port').with({'value' => 8140})
        }
      end
    end
  end
end
