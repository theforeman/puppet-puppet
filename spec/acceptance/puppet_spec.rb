require 'spec_helper_acceptance'

describe 'Scenario: install puppet' do
  before(:context) do
    on default, 'puppet resource service puppet ensure=stopped enable=false'
  end

  it_behaves_like 'an idempotent resource' do
    let(:manifest) { 'include puppet' }
  end

  describe service('puppet') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
end
