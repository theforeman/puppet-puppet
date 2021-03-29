require 'spec_helper_acceptance'

describe 'Fact test', unless: unsupported_puppetserver do
  let(:pp) do
    <<-MANIFEST
    notify { $facts['service_provider']: }
    MANIFEST
  end

  it_behaves_like 'a idempotent resource'

  # TODO: temporary - will fail
  it { expect(fact('service_provider')).to eq('systemd') }
end
