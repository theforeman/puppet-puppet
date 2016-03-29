require 'spec_helper'

describe 'puppet::server::service' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    next if os_facts[:osfamily] == 'windows'
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :clientcert             => 'puppetmaster.example.com',
          :concat_basedir         => '/nonexistant',
          :fqdn                   => 'puppetmaster.example.com',
          :puppetversion          => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        additional_facts = {}
      else
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      let(:facts) { default_facts.merge(additional_facts) }

      describe 'default_parameters' do
        it { should_not contain_service('puppetmaster') }
        it { should_not contain_service('puppetserver') }
      end

      describe 'when puppetmaster => true' do
        let(:params) { {:puppetmaster => true, :puppetserver => Undef.new} }
        it do
          should contain_service('puppetmaster').with({
            :ensure => 'running',
            :enable => 'true',
          })
        end
      end

      describe 'when puppetserver => true' do
        let(:params) { {:puppetserver => true, :puppetmaster => Undef.new} }
        it do
          should contain_service('puppetserver').with({
            :ensure => 'running',
            :enable => 'true',
          })
        end
      end

      describe 'when puppetmaster => false' do
        let(:params) { {:puppetmaster => false} }
        it do
          should contain_service('puppetmaster').with({
            :ensure => 'stopped',
            :enable => 'false',
          })
        end
      end

      describe 'when puppetserver => false' do
        let(:params) { {:puppetserver => false} }
        it do
          should contain_service('puppetserver').with({
            :ensure => 'stopped',
            :enable => 'false',
          })
        end
      end

      describe 'when puppetmaster => undef' do
        let(:params) { {:puppetmaster => Undef.new} }
        it { should_not contain_service('puppetmaster') }
      end

      describe 'when puppetserver => undef' do
        let(:params) { {:puppetserver => Undef.new} }
        it { should_not contain_service('puppetserver') }
      end

      describe 'when puppetmaster => true and puppetserver => true' do
        let(:params) { {:puppetserver => true, :puppetmaster => true} }
        it { should raise_error(Puppet::Error, /Both puppetmaster and puppetserver cannot be enabled simultaneously/) }
      end

    end
  end
end
