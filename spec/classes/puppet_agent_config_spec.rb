require 'spec_helper'

describe 'puppet::agent::config' do

  on_supported_os.each do |os, facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    next if facts[:osfamily] == 'windows' # TODO, see https://github.com/fessyfoo/rspec-puppet-windows-issue
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/foo/bar',
          :puppetversion  => Puppet.version,
        })
      end

      context 'with default parameters' do
        let :pre_condition do
          'include ::puppet'
        end

        it { should compile.with_all_deps }
        it { should contain_concat__fragment( 'puppet.conf_agent' ) }
        if facts[:osfamily] == 'Debian'
          it { should contain_augeas('puppet::set_start').
               with_context('/files/etc/default/puppet').
               with_changes('set START yes').
               with_incl('/etc/default/puppet').
               with_lens('Shellvars.lns').
               with({})
          }
          it { should contain_file('/var/lib/puppet/state/agent_disabled.lock').
               with_ensure(:absent).
               with({})
          }
        end
      end

      context 'with runmode => cron' do
        let :pre_condition do
          'class { "::puppet": runmode => "cron" }'
        end

        it { should compile.with_all_deps }
        it { should contain_concat__fragment( 'puppet.conf_agent' ) }
        if facts[:osfamily] == 'Debian'
          it { should contain_augeas('puppet::set_start').
               with_context('/files/etc/default/puppet').
               with_changes('set START no').
               with_incl('/etc/default/puppet').
               with_lens('Shellvars.lns').
               with({})
          }
          it { should contain_file('/var/lib/puppet/state/agent_disabled.lock').
               with_ensure(:absent).
               with({})
          }
        end
      end

      context 'with remove_lock => false' do
        let :pre_condition do
          'class { "::puppet": remove_lock => false }'
        end

        it { should compile.with_all_deps }
        it { should contain_concat__fragment( 'puppet.conf_agent' ) }
        if facts[:osfamily] == 'Debian'
          it { should contain_augeas('puppet::set_start').
               with_context('/files/etc/default/puppet').
               with_changes('set START yes').
               with_incl('/etc/default/puppet').
               with_lens('Shellvars.lns').
               with({})
          }
          it { should_not contain_file('/var/lib/puppet/state/agent_disabled.lock') }
        end
      end
    end
  end
end
