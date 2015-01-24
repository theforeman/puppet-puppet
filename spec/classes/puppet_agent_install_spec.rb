require 'spec_helper'

describe 'puppet::agent::install' do

  describe 'with default parameters' do
    let :pre_condition do
      'include ::puppet'
    end

    context "on a RedHat family OS" do
      let :facts do {
        :osfamily => 'RedHat',
      } end

      it 'should not define provider' do
        should contain_package('puppet').without_provider(nil)
      end
    end

    context "on a Windows family OS" do
      let :facts do {
        :osfamily => 'windows',
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
    } end

    it 'should define provider as msi' do
      should contain_package('puppet').with_provider('msi')
    end

  end

end
