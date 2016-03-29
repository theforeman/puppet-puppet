require 'spec_helper'

describe 'puppet::agent::install' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :concat_basedir         => '/nonexistant',
          :puppetversion          => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        if os_facts[:osfamily] == 'FreeBSD'
          client_package = 'puppet38'
        else
          client_package = 'puppet'
        end
        additional_facts = {}
      else
        if os_facts[:osfamily] == 'FreeBSD'
          client_package = 'puppet4'
          additional_facts = {}
        else
          client_package = 'puppet-agent'
          if os_facts[:osfamily] == 'windows'
            additional_facts = {}
          else
            additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
          end
        end
      end

      let (:facts) do
        default_facts.merge(additional_facts)
      end

      describe 'with default parameters' do
        let :pre_condition do
          'include ::puppet'
        end

        if os_facts[:osfamily] == 'windows'
          it 'should define provider as chocolatey on Windows' do
            should contain_package(client_package).with_provider('chocolatey')
          end
        else
          it 'should not define provider on non-Windows' do
            should contain_package(client_package).without_provider(nil)
          end
        end
      end

      describe "when manage_packages => false" do
        let :pre_condition do
          "class { 'puppet': manage_packages => false }"
        end

        it 'should not contain Package[puppet]' do
          should_not contain_package('puppet')
        end

        it 'should not contain Package[puppet-agent]' do
          should_not contain_package('puppet-agent')
        end
      end

      describe "when manage_packages => 'agent'" do
        let :pre_condition do
          "class { 'puppet': manage_packages => 'agent' }"
        end

        it 'should contain Package[puppet]' do
          should contain_package(client_package)
        end
      end

      describe "when manage_packages => 'server'" do
        let :pre_condition do
          "class { 'puppet': manage_packages => 'server' }"
        end

        it 'should not contain Package[puppet]' do
          should_not contain_package('puppet')
        end

        it 'should not contain Package[puppet-agent]' do
          should_not contain_package('puppet-agent')
        end
      end

      if os_facts[:osfamily] == 'windows'
        describe "when package_provider => 'msi'" do
          let :pre_condition do
            "class { 'puppet': package_provider => 'msi', }"
          end

          it 'should define provider as msi' do
            should contain_package(client_package).with_provider('msi')
          end
        end

        describe "when package_provider => 'windows' and source is defined" do
          let :pre_condition do
            "class { 'puppet': package_provider => 'windows', package_source => 'C:\\Temp\\puppet.exe' }"
          end

          it 'should define provider as windows' do
            should contain_package(client_package).with_provider('windows')
          end

          it 'should define source as C:\Temp\puppet.exe' do
            should contain_package(client_package).with_source('C:\Temp\puppet.exe')
          end
        end
      end
    end
  end
end
