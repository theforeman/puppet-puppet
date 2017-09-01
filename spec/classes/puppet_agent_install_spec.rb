require 'spec_helper'

describe 'puppet::agent::install' do
  context 'with explicit parameters' do
    let :base_params do
      {
        :manage_packages  => true,
        :package_name     => 'puppet-agent',
        :package_version  => 'installed',
        :package_provider => 'provider', # Can't set this to nil
        :package_source   => 'source', # Can't set this to nil
      }
    end

    describe 'base parameters' do
      let :params do
        base_params
      end

      it do
        is_expected.to contain_package('puppet-agent').
          with_ensure('installed').
          with_provider('provider').
          with_source('source')
      end
    end

    describe 'when manage_packages => false' do
      let :params do
        base_params.merge(:manage_packages => false)
      end

      it { is_expected.not_to contain_package('puppet-agent') }
    end

    describe "when manage_packages => 'agent'" do
      let :params do
        base_params.merge(:manage_packages => 'agent')
      end

      it { is_expected.to contain_package('puppet-agent') }
    end

    describe "when manage_packages => 'server'" do
      let :params do
        base_params.merge(:manage_packages => 'sever')
      end

      it { is_expected.not_to contain_package('puppet-agent') }
    end
  end

  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      client_package = if facts[:osfamily] == 'FreeBSD'
                         if Puppet.version < '5.0'
                           'puppet4'
                         else
                           'puppet5'
                         end
                       else
                         'puppet-agent'
                       end

      package_provider = if facts[:osfamily] == 'windows'
                           'chocolatey'
                         else
                           nil
                         end

      let (:facts) do
        facts
      end

      describe 'with default parameters' do
        let :pre_condition do
          'include ::puppet'
        end

        # For windows we specify a package provider which doesn't compile
        if facts[:osfamily] != 'windows'
          it { is_expected.to compile.with_all_deps }
        end

        it do
          is_expected.to contain_class('puppet::agent::install').
            with_manage_packages(true).
            with_package_name([client_package]).
            with_package_version('present').
            with_package_provider(package_provider).
            with_package_source(nil)
        end

        it do
          is_expected.to contain_package(client_package).
            with_ensure('present').
            with_provider(package_provider).
            with_source(nil)
        end
      end
    end
  end
end
