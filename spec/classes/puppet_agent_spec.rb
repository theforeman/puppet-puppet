require 'spec_helper'

describe 'puppet::agent' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      case facts[:osfamily]
      when 'FreeBSD'
        if Puppet.version < '5.0'
          client_package = 'puppet4'
        else
          client_package = 'puppet5'
        end
        confdir          = '/usr/local/etc/puppet'
      when 'windows'
        client_package = 'puppet-agent'
        confdir        = 'C:/ProgramData/PuppetLabs/puppet/etc'
      else
        client_package = 'puppet-agent'
        confdir        = '/etc/puppetlabs/puppet'
      end

      let :facts do
        facts
      end

      describe 'with no custom parameters' do
        let :pre_condition do
          "class {'puppet': agent => true}"
        end
        it { should contain_class('puppet::agent::install') }
        it { should contain_class('puppet::agent::config') }
        it { should contain_class('puppet::agent::service') }
        it { should contain_file(confdir).with_ensure('directory') }
        it { should contain_concat("#{confdir}/puppet.conf") }
        it { should contain_package(client_package).with_ensure('present') }
        it do
          should contain_concat__fragment('puppet.conf_agent').
            with_content(/^\[agent\]/).
            with({})
        end

        it do
          should_not contain_puppet__config__agent('prerun_command')
        end

        it do
          should_not contain_puppet__config__agent('postrun_command')
        end
      end

      describe 'set prerun_command will be included in config' do
        let(:pre_condition) { "class {'puppet': agent => true, prerun_command => '/my/prerun'}" }
        it do
          should contain_puppet__config__agent('prerun_command').with({'value'  => '/my/prerun'})
        end
      end

      describe 'set postrun_command will be included in config' do
        let(:pre_condition) { "class {'puppet': agent => true, postrun_command => '/my/postrun'}" }
        it do
          should contain_puppet__config__agent('postrun_command').with({'value'  => '/my/postrun'})
        end
      end

      describe 'with additional settings' do
        let :pre_condition do
          "class {'puppet':
              agent_additional_settings => {ignoreschedules => true},
           }"
        end

        it 'should configure puppet.conf' do
          should contain_puppet__config__agent('ignoreschedules').with({'value'  => 'true'})
        end
      end

    end
  end
end
