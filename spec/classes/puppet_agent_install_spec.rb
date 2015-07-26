require 'spec_helper'

describe 'puppet::agent::install' do

  if Puppet.version < '4.0'
    additional_facts = {}
  else
    additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
  end

  let :common_centos_facts do on_supported_os['centos-6-x86_64'].merge({
    :concat_basedir => '/nonexistant',
    :puppetversion  => Puppet.version,
  }).merge(additional_facts) end

  describe 'with default parameters' do
    let :pre_condition do
      'include ::puppet'
    end

    if Puppet.version < '4.0'
      client_package = 'puppet'
    else
      client_package = 'puppet-agent'
    end

    context "on a RedHat family OS" do
      let :facts do
        common_centos_facts
      end

      it 'should not define provider' do
        should contain_package(client_package).without_provider(nil)
      end
    end

    context "on a Windows family OS" do
      let :facts do
        {
          :osfamily => 'windows',
          :concat_basedir => 'C:\Temp',
          :puppetversion => Puppet.version,
        }
      end

      it 'should define provider as chocolatey' do
        should contain_package(client_package).with_provider('chocolatey')
      end
    end

  end

  describe "when package_provider => 'msi'" do

    if Puppet.version < '4.0'
      client_package = 'puppet'
    else
      client_package = 'puppet-agent'
    end

    let :pre_condition do
      "class { 'puppet': package_provider => 'msi', }"
    end

    let :facts do
      {
        :osfamily => 'windows',
        :concat_basedir => 'C:\Temp',
        :puppetversion => Puppet.version,
      }
    end

    it 'should define provider as msi' do
      should contain_package(client_package).with_provider('msi')
    end

  end

  describe "when package_provider => 'windows' and source is defined" do

    if Puppet.version < '4.0'
      client_package = 'puppet'
    else
      client_package = 'puppet-agent'
    end

    let :pre_condition do
      "class { 'puppet': package_provider => 'windows', package_source => 'C:\\Temp\\puppet.exe' }"
    end

    let :facts do
      {
        :osfamily => 'windows',
        :concat_basedir => 'C:\Temp',
        :puppetversion => Puppet.version,
      }
    end

    it 'should define provider as windows' do
      should contain_package(client_package).with_provider('windows')
    end

    it 'should define source as C:\Temp\puppet.exe' do
      should contain_package(client_package).with_source('C:\Temp\puppet.exe')
    end

  end

  describe "when manage_packages => false" do
    let :pre_condition do
      "class { 'puppet': manage_packages => false }"
    end

    context "on a RedHat family OS" do
      let :facts do
        common_centos_facts
      end

      it 'should not contain Package[puppet]' do
        should_not contain_package('puppet')
      end

      it 'should not contain Package[puppet-agent]' do
        should_not contain_package('puppet-agent')
      end
    end
  end

  describe "when manage_packages => 'agent'" do
    let :pre_condition do
      "class { 'puppet': manage_packages => 'agent' }"
    end

    if Puppet.version < '4.0'
      client_package = 'puppet'
    else
      client_package = 'puppet-agent'
    end

    context "on a RedHat family OS" do
      let :facts do
        common_centos_facts
      end

      it 'should contain Package[puppet]' do
        should contain_package(client_package)
      end
    end
  end

  describe "when manage_packages => 'server'" do
    let :pre_condition do
      "class { 'puppet': manage_packages => 'server' }"
    end

    context "on a RedHat family OS" do
      let :facts do
        common_centos_facts
      end

      it 'should not contain Package[puppet]' do
        should_not contain_package('puppet')
      end

      it 'should not contain Package[puppet-agent]' do
        should_not contain_package('puppet-agent')
      end
    end
  end
end
