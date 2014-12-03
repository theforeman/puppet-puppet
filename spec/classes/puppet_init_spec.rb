require 'spec_helper'

describe 'puppet' do
  context 'on RedHat' do
      let :facts do {
        :clientcert             => 'puppetmaster.example.com',
        :concat_basedir         => '/nonexistant',
        :fqdn                   => 'puppetmaster.example.com',
        :operatingsystemrelease => '6.5',
        :osfamily               => 'RedHat',
      } end

      describe 'with no custom parameters' do
        it { should contain_class('puppet::config') }
        it { should contain_file('/etc/puppet').with_ensure('directory') }
        it { should contain_file('/etc/puppet/puppet.conf') }
        it { should contain_package('puppet').with_ensure('present') }
      end

      describe 'with empty ca_server' do
        let :params do {
          :ca_server => '',
        } end

        it { should_not contain_concat_fragment('puppet.conf+10-main').with_content(/ca_server/) }
      end

      describe 'with ca_server' do
        let :params do {
          :ca_server => 'ca.example.org',
        } end

        it { should contain_concat_fragment('puppet.conf+10-main').with_content(/^\s+ca_server\s+= ca.example.org$/) }
      end

      describe 'with empty ca_port' do
        let :params do {
          :ca_port => '',
        } end

        it { should_not contain_concat_fragment('puppet.conf+10-main').with_content(/ca_port/) }
      end

      describe 'with ca_port' do
        let :params do {
          :ca_port => '8140',
        } end

        it { should contain_concat_fragment('puppet.conf+10-main').with_content(/^\s+ca_port\s+= 8140$/) }
      end

      describe 'with ca_port' do
        let :params do {
          :ca_port => 8140,
        } end

        it { should contain_concat_fragment('puppet.conf+10-main').with_content(/^\s+ca_port\s+= 8140$/) }
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
  end

  context 'on Windows' do
    let :facts do {
      :clientcert             => 'puppetmaster.example.com',
      :concat_basedir         => '/nonexistant',
      :fqdn                   => 'puppetmaster.example.com',
      :operatingsystemrelease => '7',
      :osfamily               => 'Windows',
    } end

    describe 'with no custom parameters' do
      it { should contain_class('puppet::config') }
      it { should contain_file('C:/ProgramData/PuppetLabs/puppet/etc').with_ensure('directory') }
      it { should contain_file('C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf') }
      it { should contain_package('puppet').with_ensure('present') }
    end
  end
end
