# frozen_string_literal: true

Facter.add('puppet_flavor') do
  confine { Facter::Core::Execution.which('puppet') }
  setcode do
    output = Facter::Core::Execution.execute('puppet --help')
    output.split[-2] if output
  end
end

