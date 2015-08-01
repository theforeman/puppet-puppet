require 'spec_helper'

describe 'puppet::agent::install' do

  describe 'with default parameters' do
    let :pre_condition do
      'include ::puppet'
    end

    context "on a RedHat family OS" do
      let :facts do {
        :osfamily => 'RedHat',
        :concat_basedir => '/foo/bar',
        :operatingsystemrelease => '6.6',
        :puppetversion => Puppet.version,
      } end

      it 'should not define provider' do
        should contain_package('puppet').without_provider(nil)
      end
    end

    context "on a Windows family OS" do
      let :facts do {
        :osfamily => 'windows',
        :concat_basedir => 'C:\Temp',
        :puppetversion => Puppet.version,
      } end

      it 'should define provider as chocolatey' do
        should contain_package('puppet').with_provider('chocolatey')
      end
    end

  end

  describe "when package_provider => 'msi'" do

    let :pre_condition do
      "class { 'puppet': package_provider => 'msi', }"
    end

    let :facts do {
      :osfamily => 'windows',
      :concat_basedir => 'C:\Temp',
      :puppetversion => Puppet.version,
    } end

    it 'should define provider as msi' do
      should contain_package('puppet').with_provider('msi')
    end

  end

  describe "when manage_packages => false" do
    let :pre_condition do
      "class { 'puppet': manage_packages => false }"
    end
    
    let :facts do {
      :osfamily => 'RedHat',
      :concat_basedir => '/foo/bar',
      :operatingsystemrelease => '6.6',
      :puppetversion => Puppet.version,
    } end
    
    it 'should not contain Package[puppet]' do
      should_not contain_package('puppet')
    end
  end
  
  describe "when manage_packages => 'agent'" do
    let :pre_condition do
      "class { 'puppet': manage_packages => 'agent' }"
    end
    
    let :facts do {
      :osfamily => 'RedHat',
      :concat_basedir => '/foo/bar',
      :operatingsystemrelease => '6.6',
      :puppetversion => Puppet.version,
    } end
    
    it 'should contain Package[puppet]' do
      should contain_package('puppet')
    end
  end
  
  describe "when manage_packages => 'server'" do
    let :pre_condition do
      "class { 'puppet': manage_packages => 'server' }"
    end
    
    let :facts do {
      :osfamily => 'RedHat',
      :concat_basedir => '/foo/bar',
      :operatingsystemrelease => '6.6',
      :puppetversion => Puppet.version,
    } end
    
    it 'should not contain Package[puppet]' do
      should_not contain_package('puppet')
    end
  end
end
