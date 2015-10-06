# This file is managed centrally by modulesync
#   https://github.com/theforeman/foreman-installer-modulesync

require 'puppetlabs_spec_helper/module_spec_helper'

require 'rspec-puppet-facts'
include RspecPuppetFacts

# Workaround for no method in rspec-puppet to pass undef through :params
class Undef
  def inspect; 'undef'; end
end

# Running tests with the LIMIT_OS environment variable set
# limits the tested platforms to the specified values.
# Example: LIMIT_OS=centos-7-x86_64,ubuntu-14-x86_64
def limit_test_os
  if ENV.key?('LIMIT_OS')
    ENV['LIMIT_OS'].split(',')
  end
end

def get_content(subject, title)
  content = subject.resource('file', title).send(:parameters)[:content]
  content.split(/\n/).reject { |line| line =~ /(^#|^$|^\s+#)/ }
end

def verify_exact_contents(subject, title, expected_lines)
  expect(get_content(subject, title)).to eq(expected_lines)
end

def verify_concat_fragment_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
    (content.split("\n") & expected_lines).should == expected_lines
end

def verify_concat_fragment_exact_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
    content.split(/\n/).reject { |line| line =~ /(^#|^$|^\s+#)/ }.should == expected_lines
end

# See https://github.com/rodjek/rspec-puppet/issues/215
# Without this patch the @@cache variable grows huge and causes memory usage issues
# with a large amount of examples.
module RSpec::Puppet
  module Support
    def build_catalog(*args)
      if @@cache.has_key?(args)
        @@cache[args]
      else
        @@cache = {}
        @@cache[args] ||= self.build_catalog_without_cache(*args)
      end
    end
  end
end
