require 'spec_helper'

describe 'puppet' do
  context 'on RedHat' do
      let :default_facts do on_supported_os['centos-6-x86_64'].merge({
        :clientcert             => 'puppetmaster.example.com',
        :concat_basedir         => '/nonexistant',
        :fqdn                   => 'puppetmaster.example.com',
        :puppetversion          => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        puppet_directory = '/etc/puppet'
        puppet_concat = '/etc/puppet/puppet.conf'
        puppet_package = 'puppet'
        additional_facts = {}
      else
        puppet_directory = '/etc/puppetlabs/puppet'
        puppet_concat = '/etc/puppetlabs/puppet/puppet.conf'
        puppet_package = 'puppet-agent'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      let :facts do
        default_facts.merge(additional_facts)
      end

      describe 'with no custom parameters' do
        it { should contain_class('puppet::config') }
        if Puppet.version < '4.0'
          it { should contain_file('/etc/puppet').with_ensure('directory') }
          it { should contain_concat('/etc/puppet/puppet.conf') }
          it { should contain_package('puppet').with_ensure('present') }
        else
          it { should contain_file('/etc/puppetlabs/puppet').with_ensure('directory') }
          it { should contain_concat('/etc/puppetlabs/puppet/puppet.conf') }
          it { should contain_package('puppet-agent').with_ensure('present') }
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

  context 'on Windows' do
    let :facts do {
      :clientcert             => 'puppetmaster.example.com',
      :concat_basedir         => '/nonexistant',
      :fqdn                   => 'puppetmaster.example.com',
      :operatingsystemrelease => '7',
      :osfamily               => 'Windows',
      :puppetversion          => Puppet.version,
    } end

    describe 'with no custom parameters' do
      it { should contain_class('puppet::config') }
      it { should contain_file('C:/ProgramData/PuppetLabs/puppet/etc').with_ensure('directory') }
      it { should contain_concat('C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf') }
      if Puppet.version < '4.0'
        it { should contain_package('puppet').with_ensure('present') }
      else
        it { should contain_package('puppet-agent').with_ensure('present') }
      end
    end
  end
end
