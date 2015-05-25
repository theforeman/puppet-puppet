require 'spec_helper'

describe 'puppet::server::passenger' do
  on_supported_os.each do |os, facts|
    let(:facts) do
      facts.merge({
        :concat_basedir => '/foo/bar',
      })
    end

    describe 'without parameters' do
      it 'should include the puppet vhost' do
        should contain_apache__vhost('puppet').with({
          :ssl_proxyengine => false,
          :ssl_crl_check => nil,
        })
      end
    end

    describe 'with puppet ca proxy' do
      let :params do {
        :puppet_ca_proxy => 'https://ca.example.org:8140',
      }  end

      it 'should include the puppet vhost' do
        should contain_apache__vhost('puppet').with({
          :ssl_proxyengine => true,
          :custom_fragment => "ProxyPassMatch ^/([^/]+/certificate.*)$ https://ca.example.org:8140/$1",
        })
      end
    end

    describe 'with SSL CRL' do
      let :params do {
        :ssl_ca_crl => '/var/lib/puppet/ssl/ca/ca_crl.pem',
      } end

      it 'should include the puppet vhost' do
        should contain_apache__vhost('puppet').with({
          :ssl_crl => '/var/lib/puppet/ssl/ca/ca_crl.pem',
          :ssl_crl_check => 'chain',
        })
      end
    end
  end
end
