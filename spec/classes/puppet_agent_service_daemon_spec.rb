require 'spec_helper'

describe 'puppet::agent::service::daemon' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :clientcert     => 'puppetmaster.example.com',
          :concat_basedir => '/nonexistant',
          :fqdn           => 'puppetmaster.example.com',
          :puppetversion  => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        confdir = '/etc/puppet'
        additional_facts = {}
      else
        confdir = '/etc/puppetlabs/puppet'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      if os_facts[:osfamily] == 'FreeBSD'
        confdir = '/usr/local/etc/puppet'
      end

      let :facts do
        default_facts.merge(additional_facts)
      end

      describe 'when runmode => daemon' do
        let :pre_condition do
          "class {'puppet': agent => true}"
        end

        it do
          should contain_service('puppet').with({
            :ensure     => 'running',
            :name       => 'puppet',
            :hasstatus  => 'true',
            :enable     => 'true',
          })
        end

        describe 'when runmode is not daemon' do
          let :pre_condition do
            "class {'puppet': agent => true, runmode => 'cron'}"
          end

          it do
            case os
            when /\Awindows/
              should raise_error(Puppet::Error, /Runmode of cron not supported on #{os_facts[:kernel]} operating systems!/)
            else
              should contain_service('puppet').with({
                :ensure     => 'stopped',
                :name       => 'puppet',
                :hasstatus  => 'true',
                :enable     => 'false',
              })
            end
          end
        end
      end

      describe 'with custom service_name' do
        let :pre_condition do
          "class {'puppet': agent => true, service_name => 'pe-puppet'}"
        end

        it do
          should contain_service('puppet').with({
            :ensure     => 'running',
            :name       => 'pe-puppet',
            :hasstatus  => 'true',
            :enable     => 'true',
          })
        end

      end
    end
  end
end
