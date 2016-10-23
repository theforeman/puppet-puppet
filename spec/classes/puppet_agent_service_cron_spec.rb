require 'spec_helper'

describe 'puppet::agent::service::cron' do
  on_os_under_test.each do |os, os_facts|
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :clientcert     => 'puppetmaster.example.com',
          :concat_basedir => '/nonexistant',
          :fqdn           => 'puppetmaster.example.com',
          :puppetversion  => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        confdir = '/etc/puppet'
        bindir = '/usr/bin'
        additional_facts = {}
      else
        confdir = '/etc/puppetlabs/puppet'
        bindir = '/opt/puppetlabs/bin'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      if os_facts[:osfamily] == 'FreeBSD'
        bindir = '/usr/local/bin'
        confdir = '/usr/local/etc/puppet'
      end

      let :facts do
        default_facts.merge(additional_facts)
      end

      describe 'when runmode is not cron' do
        let :pre_condition do
          "class {'puppet': agent => true}"
        end

        if os =~ /\A(windows|archlinux)/
          it { should_not contain_cron('puppet') }
        else
          it { should contain_cron('puppet').with_ensure('absent') }
        end
      end

      describe 'when runmode => cron' do
        let :pre_condition do
          "class {'puppet': agent => true, runmode => 'cron'}"
        end

        it do
          case os
          when /\A(windows|archlinux)/
            should raise_error(Puppet::Error, /Runmode of cron not supported on #{os_facts[:kernel]} operating systems!/)
          else
            should contain_cron('puppet').with({
              :command  => "#{bindir}/puppet agent --config #{confdir}/puppet.conf --onetime --no-daemonize",
              :user     => 'root',
              :minute   => ['15','45'],
              :hour     => '*',
            })
          end
        end
      end
    end
  end
end
