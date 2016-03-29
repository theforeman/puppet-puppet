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
        it { should contain_class('puppet::config') }
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

      describe 'with empty ca_server' do
        let :params do {
          :ca_server => '',
        } end

        it { should_not contain_concat__fragment('puppet.conf+10-main').with_content(/ca_server/) }
      end

      describe 'with ca_server' do
        let :params do {
          :ca_server => 'ca.example.org',
        } end

        it { should contain_concat__fragment('puppet.conf+10-main').with_content(/^\s+ca_server\s+= ca.example.org$/) }
      end

      describe 'with empty ca_port' do
        let :params do {
          :ca_port => '',
        } end

        it { should_not contain_concat__fragment('puppet.conf+10-main').with_content(/ca_port/) }
      end

      describe 'with ca_port' do
        let :params do {
          :ca_port => '8140',
        } end

        it { should contain_concat__fragment('puppet.conf+10-main').with_content(/^\s+ca_port\s+= 8140$/) }
      end

      describe 'with ca_port' do
        let :params do {
          :ca_port => 8140,
        } end

        it { should contain_concat__fragment('puppet.conf+10-main').with_content(/^\s+ca_port\s+= 8140$/) }
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

      # Test validate_string parameters
      [
        :hiera_config,
      ].each do |p|
        context "when #{p} => ['foo']" do
          let(:params) {{ p => ['foo'] }}
          it { should raise_error(Puppet::Error, /is not a string/) }
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

      describe 'when an invalid jvm size value is given' do
        context "when server_jvm_min_heap_size => 'x4m'" do
          let (:params) {{
            :server_jvm_min_heap_size => 'x4m',
            :server_jvm_max_heap_size => '2G',
            :server_implementation    => 'puppetserver',
          }}
          it { should raise_error(Puppet::Error, /does not match "\^\[0-9\]\+\[kKmMgG\]\$"/) }
        end
        context "when server_jvm_max_heap_size => 'x4m'" do
          let (:params) {{
            :server_jvm_max_heap_size => 'x4m',
            :server_jvm_min_heap_size => '2G',
            :server_implementation    => 'puppetserver',
          }}
          it { should raise_error(Puppet::Error, /does not match "\^\[0-9\]\+\[kKmMgG\]\$"/) }
        end
      end
    end
  end
end
