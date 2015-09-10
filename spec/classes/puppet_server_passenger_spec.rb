require 'spec_helper'

describe 'puppet::server::passenger' do
  on_supported_os.each do |os, facts|
    let(:facts) do
      facts.merge({
        :concat_basedir => '/foo/bar',
        :puppetversion  => Puppet.version,
      })
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

    describe 'with passenger settings' do
      let :pre_condition do
        "class {'puppet':
           server                          => true,
           server_passenger                => true,
           server_implementation           => 'master',
           server_app_root                 => '/etc/puppet/rack',
           server_passenger_max_pool_size  => 20,
           server_passenger_max_requests   => 1000,
           server_passenger_pool_idle_time => 1000,
         }"
      end

      it 'should include the mod passenger' do
        should contain_apache__mod('passenger')
      end

      it 'should have passenger.conf' do
        is_expected.to contain_file('passenger.conf').with({
          'path' => '/etc/apache2/mods-available/passenger.conf'}).
          with_content(/PassengerHighPerformance Off$/).
          with_content(/PassengerMaxPoolSize 20$/).
          with_content(/PassengerMaxRequests 1000$/).
          with_content(/PassengerPoolIdleTime 1000$/)
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
