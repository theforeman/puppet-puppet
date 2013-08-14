require 'spec_helper'

describe 'puppet::server::passenger' do
  let :facts do
    {
      :osfamily   => 'RedHat',
      :fqdn       => 'puppetmaster.example.com',
      :clientcert => 'puppetmaster.example.com',
    }
  end

  describe 'with no custom parameters' do
    let :pre_condition do
      "
      class {'puppet': server => true}
      "
    end

    it 'should include the puppet vhost' do
      should contain_file('puppet_vhost').
        with_content(/^Listen 8140$/).
        with_content(/^<VirtualHost \*:8140>$/).
        with_content(/^  SSLCertificateFile\s+\/var\/lib\/puppet\/ssl\/certs\/#{facts[:fqdn]}.pem$/).
        with_content(/^  SSLCertificateKeyFile\s+\/var\/lib\/puppet\/ssl\/private_keys\/#{facts[:fqdn]}.pem$/).
        with_content(/^  SSLCACertificateFile\s+\/var\/lib\/puppet\/ssl\/ca\/ca_crt.pem$/).
        with_content(/^  SSLCertificateChainFile\s+\/var\/lib\/puppet\/ssl\/ca\/ca_crt.pem$/).
        with_content(/^  SSLCARevocationFile\s+\/var\/lib\/puppet\/ssl\/ca\/ca_crl.pem$/).
        with_content(/^  DocumentRoot \/etc\/puppet\/rack\/public\/$/).
        with_content(/^  <Directory \/etc\/puppet\/rack>$/).
        with_content(/^  PassengerMaxPoolSize 12$/).
        with({
          :path    => '/etc/httpd/conf.d/puppet.conf',
          :mode    => '0644',
          :notify  => 'Exec[reload-apache]',
          :before  => /Service\[httpd\]/,
          :require => /Class\[Puppet::Server::Rack\]/,
        })
    end
  end

  describe 'with no custom parameters' do
    let :pre_condition do
      "
      class {'puppet':
        server                    => true,
        server_passenger_max_pool => 6,
      }
      "
    end
    it 'should override PassengerMaxPoolSize' do
      should contain_file('puppet_vhost').with_content(/^  PassengerMaxPoolSize 6$/)
    end
  end

end
