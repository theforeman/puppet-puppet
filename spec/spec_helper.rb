# This file is managed centrally by modulesync
#   https://github.com/theforeman/foreman-installer-modulesync

require 'voxpupuli/test/spec_helper'

# Rough conversion of grepping in the puppet source:
# grep defaultfor lib/puppet/provider/service/*.rb
add_custom_fact :service_provider, ->(os, facts) do
  case facts[:osfamily].downcase
  when 'archlinux'
    'systemd'
  when 'darwin'
    'launchd'
  when 'debian'
    'systemd'
  when 'freebsd'
    'freebsd'
  when 'gentoo'
    'openrc'
  when 'openbsd'
    'openbsd'
  when 'redhat'
    facts[:operatingsystemrelease].to_i >= 7 ? 'systemd' : 'redhat'
  when 'suse'
    facts[:operatingsystemmajrelease].to_i >= 12 ? 'systemd' : 'redhat'
  when 'windows'
    'windows'
  else
    'init'
  end
end

def get_content(subject, title)
  is_expected.to contain_file(title)
  content = subject.resource('file', title).send(:parameters)[:content]
  content.split(/\n/).reject { |line| line =~ /(^#|^$|^\s+#)/ }
end

def verify_exact_contents(subject, title, expected_lines)
  expect(get_content(subject, title)).to match_array(expected_lines)
end

def verify_concat_fragment_contents(subject, title, expected_lines)
  is_expected.to contain_concat__fragment(title)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  expect(content.split("\n") & expected_lines).to match_array(expected_lines)
end

def verify_concat_fragment_exact_contents(subject, title, expected_lines)
  is_expected.to contain_concat__fragment(title)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  expect(content.split(/\n/).reject { |line| line =~ /(^#|^$|^\s+#)/ }).to match_array(expected_lines)
end

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
