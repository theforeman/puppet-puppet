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
        :app_root => '/etc/puppet/rack'
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

    end
  end
end
