require 'spec_helper'

describe 'puppet::config::entry' do
  on_supported_os.each do |os, facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    context "on #{os}" do
      let(:default_facts) do
        facts.merge({
          :clientcert       => 'puppetmaster.example.com',
          :concat_basedir   => '/nonexistant',
          :fqdn             => 'puppetmaster.example.com',
          :rubyversion      => '1.9.3',
          :puppetversion    => Puppet.version,
        })
      end

      if Puppet.version < '4.0'
        codedir = '/etc/puppet'
        confdir = '/etc/puppet'
        logdir  = '/var/log/puppet'
        rundir  = '/var/run/puppet'
        ssldir  = '/var/lib/puppet/ssl'
        vardir  = '/var/lib/puppet'
        sharedir = '/usr/share/puppet'
        additional_facts = {}
      else
        codedir = '/etc/puppetlabs/code'
        confdir = '/etc/puppetlabs/puppet'
        logdir  = '/var/log/puppetlabs/puppet'
        rundir  = '/var/run/puppetlabs'
        ssldir  = '/etc/puppetlabs/puppet/ssl'
        vardir  = '/opt/puppetlabs/puppet/cache'
        sharedir = '/opt/puppetlabs/puppet'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      if facts[:osfamily] == 'FreeBSD'
        codedir = '/usr/local/etc/puppet'
        confdir = '/usr/local/etc/puppet'
        logdir  = '/var/log/puppet'
        rundir  = '/var/run/puppet'
        ssldir  = '/var/puppet/ssl'
        vardir  = '/var/puppet'
        sharedir = '/usr/local/share/puppet'
      end

      let(:facts) { default_facts.merge(additional_facts) }

      let(:title) { 'foo' }

      context 'with a plain value' do
        let :pre_condition do
          "class {'puppet': }"
        end
        let :params do
          {
            :key          => 'foo',
            :value        => 'bar',
            :section      => 'main',
            :sectionorder => 1,
          }
        end
        it 'should contain the section header' do
          should contain_concat__fragment('puppet.conf_main').with_content("\n\n[main]")
          should contain_concat__fragment('puppet.conf_main').with_order("1_main ")
        end
        it 'should contain the keyvalue pair' do
          should contain_concat__fragment('puppet.conf_main_foo').with_content(/^\s+foo = bar$/)
          should contain_concat__fragment('puppet.conf_main_foo').with_order("1_main_foo ")
        end
      end
      context 'with an array value' do
        let :pre_condition do
          "class {'puppet': }"
        end
        let :params do
          {
            :key          => 'foo',
            :value        => ['bar','baz'],
            :section      => 'main',
            :sectionorder => 1,
          }
        end
        it 'should contain the section header' do
          should contain_concat__fragment('puppet.conf_main').with_content("\n\n[main]")
          should contain_concat__fragment('puppet.conf_main').with_order("1_main ")
        end
        it 'should contain the keyvalue pair' do
          should contain_concat__fragment('puppet.conf_main_foo').with_content(/^\s+foo = bar,baz$/)
          should contain_concat__fragment('puppet.conf_main_foo').with_order("1_main_foo ")
        end
      end
      context 'with a custom joiner' do
        let :pre_condition do
          "class {'puppet': }"
        end
        let :params do
          {
            :key          => 'foo',
            :value        => ['bar','baz'],
            :joiner       => ':',
            :section      => 'main',
            :sectionorder => 1,
          }
        end
        it 'should contain the section header' do
          should contain_concat__fragment('puppet.conf_main').with_content("\n\n[main]")
          should contain_concat__fragment('puppet.conf_main').with_order("1_main ")
        end
        it 'should contain the keyvalue pair' do
          should contain_concat__fragment('puppet.conf_main_foo').with_content(/^\s+foo = bar:baz$/)
          should contain_concat__fragment('puppet.conf_main_foo').with_order("1_main_foo ")
        end
      end

    end
  end
end
