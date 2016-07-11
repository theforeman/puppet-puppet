require 'spec_helper'

describe 'puppet' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :clientcert     => 'puppetmaster.example.com',
          :concat_basedir => '/nonexistant',
          :fqdn           => 'puppetmaster.example.com',
          :puppetversion  => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        puppet_concat    = '/etc/puppet/puppet.conf'
        puppet_directory = '/etc/puppet'
        puppet_package   = 'puppet'
        additional_facts = {}
        case os_facts[:osfamily]
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
        case os_facts[:osfamily]
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
        default_facts.merge(additional_facts)
      end

      describe 'with no custom parameters' do
        it { is_expected.to compile.with_all_deps unless os_facts[:osfamily] == 'windows' }
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

      describe 'with server => true', :unless => (os_facts[:osfamily] == 'windows') do
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

      describe 'with empty ca_port' do
        let :params do {
          :ca_port => '',
        } end

        it {
          should_not contain_puppet__config__main('ca_port')
        }
      end

      describe 'with ca_port' do
        let :params do {
          :ca_port => '8140',
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

      # Test validate_array parameters
      [
        :dns_alt_names,
      ].each do |p|
        context "when #{p} => 'foo'" do
          let(:params) {{ p => 'foo' }}
          it { should raise_error(Puppet::Error, /is not an Array/) }
        end
      end

      describe 'when directories are not absolute paths' do
        [
          'dir', 'logdir', 'rundir'
        ].each do |d|
          context "when #{d} => './somedir'" do
            let(:params) {{ d => './somedir'}}
            it { should raise_error(Puppet::Error, /is not an absolute path/) }
          end
        end
      end

    end
  end
end
