require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "vendor/**/*.pp"]
PuppetLint.configuration.log_format = '%{path}:%{linenumber}:%{KIND}: %{message}'

RSpec::Core::RakeTask.new(:rspec) do |t|
  t.rspec_opts = File.read("spec/spec.opts").chomp || ""
end

task :default => [:rspec, :lint]
