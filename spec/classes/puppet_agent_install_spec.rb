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

      if Puppet.version < '4.0'
        it 'should not define provider' do
          should contain_package('puppet').without_provider(nil)
        end
      else
        it 'should not define provider' do
          should contain_package('puppet-agent').without_provider(nil)
        end
      end
    end

    context "on a Windows family OS" do
      let :facts do {
        :osfamily => 'windows',
        :concat_basedir => 'C:\Temp',
        :puppetversion => Puppet.version,
      } end

      if Puppet.version < '4.0'
        it 'should define provider as chocolatey' do
          should contain_package('puppet').with_provider('chocolatey')
        end
      else
        it 'should define provider as chocolatey' do
          should contain_package('puppet-agent').with_provider('chocolatey')
        end
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

    if Puppet.version < '4.0'
      it 'should define provider as msi' do
        should contain_package('puppet').with_provider('msi')
      end
    else
      it 'should define provider as msi' do
        should contain_package('puppet-agent').with_provider('msi')
      end
    end

  end

end
