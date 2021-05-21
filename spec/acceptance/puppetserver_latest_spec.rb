require 'spec_helper_acceptance'

describe 'Scenario: install puppetserver (latest):', unless: unsupported_puppetserver do
  before(:context) do
    if check_for_package(default, 'puppetserver')
      on default, puppet('resource package puppetserver ensure=purged')
      on default, 'rm -rf /etc/sysconfig/puppetserver /etc/puppetlabs/puppetserver'
      on default, 'find /etc/puppetlabs/puppet/ssl/ -type f -delete'
    end

    # puppetserver won't start with lower than 2GB memory
    memoryfree_mb = fact('memoryfree_mb').to_i
    raise 'At least 2048MB free memory required' if memoryfree_mb < 256
  end

  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<-EOS
      class { 'puppet':
        server => true,
      }
      EOS
    end
  end
end
