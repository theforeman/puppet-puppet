require 'spec_helper'

describe 'puppet::server::passenger' do
  let :facts do {
    :concat_basedir         => '/nonexistant',
    :osfamily               => 'RedHat',
    :operatingsystemrelease => '6.5',
  } end

  it 'should include the puppet vhost' do
    should contain_apache__vhost('puppet')
  end
end
