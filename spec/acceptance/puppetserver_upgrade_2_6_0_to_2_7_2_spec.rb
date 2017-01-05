require 'spec_helper_acceptance'

describe 'Scenario: 2.6.0 to 2.7.2 upgrade:' do
  before(:context) do
    if check_for_package(default, 'puppetserver')
      on(
        default,
        'rpm --erase puppetserver && ' \
        'rm -rf /etc/sysconfig/puppetserver /etc/puppetlabs/puppetserver && ' \
        'find /etc/puppetlabs/puppet/ssl/ -type f -delete'
      )
    end

    # puppetserver won't start with lower than 2GB memory
    memoryfree_mb = fact('memoryfree_mb').to_i
    raise 'At least 2048MB free memory required' if memoryfree_mb < 256
  end

  context 'install 2.6.0' do
    let(:pp) do
      <<-EOS
      class { '::puppet':
        server                => true,
        server_foreman        => false,
        server_reports        => 'store',
        server_external_nodes => '',
        server_version        => '2.6.0',
        # only for install test - don't think to use this in production!
        # https://docs.puppet.com/puppetserver/latest/tuning_guide.html
        server_jvm_max_heap_size => '256m',
        server_jvm_min_heap_size => '256m',
      }
      EOS
    end

    it_behaves_like 'a idempotent resource'

    describe command('puppetserver --version') do
      its(:stdout) { is_expected.to match("puppetserver version: 2.6.0\n") }
    end

    describe service('puppetserver') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port('8140') do
      it { is_expected.to be_listening }
    end
  end

  context 'upgrade to 2.7.2' do
    let(:pp) do
      <<-EOS
      class { '::puppet':
        server                => true,
        server_foreman        => false,
        server_reports        => 'store',
        server_external_nodes => '',
        server_version        => '2.7.2',
        # only for install test - don't think to use this in production!
        # https://docs.puppet.com/puppetserver/latest/tuning_guide.html
        server_jvm_max_heap_size => '256m',
        server_jvm_min_heap_size => '256m',
      }
      EOS
    end

    it_behaves_like 'a idempotent resource'

    describe command('puppetserver --version') do
      its(:stdout) { is_expected.to match("puppetserver version: 2.7.2\n") }
    end

    describe service('puppetserver') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port('8140') do
      it { is_expected.to be_listening }
    end
  end
end
