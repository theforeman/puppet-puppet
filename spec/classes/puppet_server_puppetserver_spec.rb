require 'spec_helper'

describe 'puppet::server::puppetserver' do
  on_supported_os.each do |os, os_facts|
    next if limit_test_os() and not limit_test_os.include?(os)
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :puppetversion          => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        additional_facts = {}
      else
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      let(:facts) { default_facts.merge(additional_facts) }

      let(:default_params) do {
        :java_bin          => '/usr/bin/java',
        :config            => '/etc/default/puppetserver',
        :jvm_min_heap_size => '2G',
        :jvm_max_heap_size => '2G',
        :jvm_extra_args    => '',
      } end

      describe 'with default parameters' do
        let(:params) { default_params }
        it { should contain_augeas('puppet::server::puppetserver::jvm').
                with_changes([
                  'set JAVA_ARGS \'"-Xms2G -Xmx2G"\'',
                  'set JAVA_BIN /usr/bin/java',
                ]).
                with_context('/files/etc/default/puppetserver').
                with_incl('/etc/default/puppetserver').
                with_lens('Shellvars.lns').
                with({})
        }
      end

      describe 'with extra_args parameter' do
        let :params do
          default_params.merge({
            :jvm_extra_args => ['-XX:foo=bar', '-XX:bar=foo'],
          })
        end

        it { should contain_augeas('puppet::server::puppetserver::jvm').
                with_changes([
                  'set JAVA_ARGS \'"-Xms2G -Xmx2G -XX:foo=bar -XX:bar=foo"\'',
                  'set JAVA_BIN /usr/bin/java',
                ]).
                with_context('/files/etc/default/puppetserver').
                with_incl('/etc/default/puppetserver').
                with_lens('Shellvars.lns').
                with({})
        }
      end

      describe 'with jvm_config file parameter' do
        let :params do
          default_params.merge({
            :config => '/etc/custom/puppetserver',
          })
        end
        it { should contain_augeas('puppet::server::puppetserver::jvm').
                with_context('/files/etc/custom/puppetserver').
                with_incl('/etc/custom/puppetserver').
                with_lens('Shellvars.lns').
                with({})
        }
      end

    end
  end
end
