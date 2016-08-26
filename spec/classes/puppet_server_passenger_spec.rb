require 'spec_helper'

describe 'puppet::server::passenger' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    next if os_facts[:osfamily] == 'windows'
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :concat_basedir         => '/foo/bar',
          :puppetversion          => Puppet.version,
          :fqdn                   => 'puppet.example.com',
      }) end

      if Puppet.version < '4.0'
        additional_facts = {}
      else
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      let :facts do
        default_facts.merge(additional_facts)
      end

      let(:default_params) do {
        :app_root => '/etc/puppet/rack',
        :confdir => '/etc/puppet',
        :vardir => '/var/lib/puppet',
        :passenger_pre_start => true,
        :passenger_min_instances => 12,
        :passenger_ruby => '/usr/bin/tfm-ruby',
        :port => 8140,
        :http => false,
        :http_port => 8139,
        :http_allow => [],
        :ssl_cert => 'cert.pem',
        :ssl_cert_key => 'key.pem',
        :ssl_ca_cert => 'ca.pem',
        :ssl_ca_crl => false,
        :ssl_chain => 'ca.pem',
        :ssl_dir => 'ssl/',
        :puppet_ca_proxy => '',
        :rack_arguments => [],
        :user => 'puppet',
      } end

      describe 'without parameters' do
        let(:params) { default_params }
        it 'should include the puppet vhost' do
          should contain_apache__vhost('puppet').with({
            :ssl_proxyengine => false,
            :ssl_crl_check => nil,
          })
        end
      end

      describe 'with puppet ca proxy' do
        let :params do
          default_params.merge({
            :puppet_ca_proxy => 'https://ca.example.org:8140',
          })
        end

        it 'should include the puppet vhost' do
          should contain_apache__vhost('puppet').with({
            :ssl_proxyengine => true,
            :custom_fragment => "ProxyPassMatch ^/([^/]+/certificate.*)$ https://ca.example.org:8140/$1",
          })
        end

        it 'should include the puppet http vhost' do
          should contain_apache__vhost('puppet').with({
            :ssl_proxyengine => true,
            :custom_fragment => "ProxyPassMatch ^/([^/]+/certificate.*)$ https://ca.example.org:8140/$1",
          })
        end
      end

      describe 'with SSL CRL' do
        let :params do
          default_params.merge({
            :ssl_ca_crl => '/var/lib/puppet/ssl/ca/ca_crl.pem',
          })
        end

        it 'should include the puppet vhost' do
          should contain_apache__vhost('puppet').with({
            :ssl_crl => '/var/lib/puppet/ssl/ca/ca_crl.pem',
            :ssl_crl_check => 'chain',
          })
        end
      end

      describe 'with passenger settings' do
        let :params do
          default_params.merge({
            :http => true,
            :passenger_min_instances => 10,
            :passenger_pre_start => true,
            :passenger_ruby => '/opt/ruby2.0/bin/ruby',
          })
        end

        it 'should include the puppet https vhost' do
          should contain_apache__vhost('puppet').with({
            :passenger_min_instances => 10,
            :passenger_pre_start     => 'https://puppet.example.com:8140',
            :passenger_ruby          => '/opt/ruby2.0/bin/ruby',
            :ssl_proxyengine         => false,
          })
        end

        it 'should include the puppet http vhost' do
          should contain_apache__vhost('puppet-http').with({
            :passenger_min_instances => 10,
            :passenger_pre_start     => 'http://puppet.example.com:8139',
            :passenger_ruby          => '/opt/ruby2.0/bin/ruby',
            :ssl_proxyengine         => false,
          })
        end
      end
    end
  end
end
