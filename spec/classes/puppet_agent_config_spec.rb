require 'spec_helper'

describe 'puppet::agent::config' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with default parameters' do
        let :pre_condition do
          'include ::puppet'
        end

        it { should compile.with_all_deps }
        it { should contain_concat_fragment( 'puppet.conf+20-agent' ) }
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
        it { should contain_concat_fragment( 'puppet.conf+20-agent' ) }
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
        it { should contain_concat_fragment( 'puppet.conf+20-agent' ) }
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
