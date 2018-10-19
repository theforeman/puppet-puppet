require 'spec_helper'

describe 'puppet::server::service' do
  context 'default parameters' do
    it { is_expected.to contain_service('puppetserver').with_ensure(true).with_enable(true) }
  end

  context 'enable => false' do
    let(:params) do
      { enable: false }
    end

    it { is_expected.to contain_service('puppetserver').with_ensure(false).with_enable(false) }
  end
end
