# This file is managed centrally by modulesync
#   https://github.com/theforeman/foreman-installer-modulesync

require 'puppetlabs_spec_helper/module_spec_helper'

require 'rspec-puppet-facts'
include RspecPuppetFacts

# Workaround for no method in rspec-puppet to pass undef through :params
class Undef
  def inspect; 'undef'; end
end

# Workaround for slow rspec-puppet-facts
def supported_os_opts
    { :supported_os => [ { "operatingsystem" => "CentOS", "operatingsystemrelease" => [ "6" ] },
                         { "operatingsystem" => "FreeBSD", "operatingsystemrelease" => [ "10" ] }
    ] }
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
