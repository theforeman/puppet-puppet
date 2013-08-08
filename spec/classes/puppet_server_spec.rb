require 'spec_helper'

describe 'puppet::server' do

  let :facts do
    {
      :osfamily   => 'RedHat',
      :fqdn       => 'puppetmaster.example.com',
      :clientcert => 'puppetmaster.example.com',
    }
  end

  describe 'with no custom parameters' do
    it 'should include classes' do
      should include_class('puppet::server::install')
      should include_class('puppet::server::config')
      should include_class('puppet::server::service')
    end
  end

end
