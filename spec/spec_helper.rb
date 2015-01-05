# This file is managed centrally by modulesync
#   https://github.com/theforeman/foreman-installer-modulesync

require 'puppetlabs_spec_helper/module_spec_helper'
require 'lib/module_spec_helper'

require 'rspec-puppet-facts'
include RspecPuppetFacts

# Workaround for no method in rspec-puppet to pass undef through :params
class Undef
  def inspect; 'undef'; end
end
