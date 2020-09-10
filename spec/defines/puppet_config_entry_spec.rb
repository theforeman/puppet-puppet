require 'spec_helper'

describe 'puppet::config::entry' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

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
