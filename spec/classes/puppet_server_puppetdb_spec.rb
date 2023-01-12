require 'spec_helper'

describe 'puppet::server::puppetdb' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}", unless: unsupported_puppetserver_osfamily(os_facts[:osfamily]) do
      let(:facts) { os_facts }
      let(:params) { {server: 'mypuppetdb.example.com'} }
      let(:pre_condition) do
        <<-PUPPET
        class { 'puppet':
          server              => true,
          server_reports      => 'puppetdb,foreman',
          server_storeconfigs => true,
        }
        PUPPET
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_puppet__config__server('storeconfigs').with_value(true) }
      it 'configures PuppetDB' do
        is_expected.to contain_class('puppetdb::master::config')
          .with_puppetdb_server('mypuppetdb.example.com')
          .with_puppetdb_port(8081)
          .with_puppetdb_soft_write_failure(false)
          .with_manage_storeconfigs(false)
          .with_restart_puppet(false)
      end
    end
  end
end
