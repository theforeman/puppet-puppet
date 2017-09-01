require 'spec_helper'

describe 'puppet::server::service' do
  on_os_under_test.each do |os, facts|
    next if facts[:osfamily] == 'windows'
    context "on #{os}" do
      if facts[:osfamily] == 'Debian'
        master_service = 'puppet-master'
      else
        master_service = 'puppetmaster'
      end

      let(:facts) do
        facts
      end

      describe 'default_parameters' do
        it { should_not contain_service(master_service) }
        it { should_not contain_service('puppetserver') }
        it { should_not contain_exec('restart_puppetmaster') }
      end

      describe 'when puppetmaster => true' do
        let(:params) { {:puppetmaster => true, :puppetserver => Undef.new} }
        it do
          should contain_service(master_service).with({
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
          should contain_service(master_service).with({
            :ensure => 'stopped',
            :enable => 'false',
          })
        end

        describe 'and rack => true' do
          let(:params) { {:puppetmaster => false, :rack => true} }
          let(:pre_condition) { 'service { "httpd": }' }
          it do
            should contain_service(master_service).with({
              :ensure => 'stopped',
              :enable => 'false',
            }).that_comes_before('Service[httpd]')
          end
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

        describe 'and rack => true' do
          let(:params) { {:puppetserver => false, :rack => true} }
          let(:pre_condition) { 'service { "httpd": }' }
          it do
            should contain_service('puppetserver').with({
              :ensure => 'stopped',
              :enable => 'false',
            }).that_comes_before('Service[httpd]')
          end
        end
      end

      describe 'when rack => true' do
        let(:params) { {:rack => true, :puppetserver => :undef, :puppetmaster => :undef, :app_root => '/etc/puppet/rack'} }
        it do
          should contain_exec('restart_puppetmaster').with({
            :command      => '/bin/touch /etc/puppet/rack/tmp/restart.txt',
            :refreshonly  => true,
            :cwd          => '/etc/puppet/rack',
          })
        end
      end

      describe 'when puppetmaster => undef' do
        let(:params) { {:puppetmaster => Undef.new} }
        it { should_not contain_service(master_service) }
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
