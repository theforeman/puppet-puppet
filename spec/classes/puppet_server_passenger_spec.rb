require 'spec_helper'

describe 'puppet::server::passenger' do
  let :facts do {
    :concat_basedir         => '/nonexistant',
    :osfamily               => 'RedHat',
    :operatingsystemrelease => '6.5',
  } end

  describe 'without parameters' do
    it 'should include the puppet vhost' do
      should contain_apache__vhost('puppet').with({
        :ssl_proxyengine => false,
      })
    end
  end

  describe 'with puppet ca' do
    let :params do {
      :puppet_ca_proxy => 'https://ca.example.org:8140',
    } end

    it 'should include the puppet vhost' do
      should contain_apache__vhost('puppet').with({
        :ssl_proxyengine => true,
        :custom_fragment => "ProxyPassMatch ^/([^/]+/certificate.*)$ https://ca.example.org:8140/$1",
      })
    end
  end
end
