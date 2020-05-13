require 'spec_helper_acceptance'

describe 'Scenario: 6.7.0 to 6.7.2 upgrade:', if: ENV['BEAKER_PUPPET_COLLECTION'] == 'puppet6', unless: unsupported_puppetserver do
  before(:context) do
    if check_for_package(default, 'puppetserver')
      on default, puppet('resource package puppetserver ensure=purged')
      on default, 'rm -rf /etc/sysconfig/puppetserver /etc/puppetlabs/puppetserver'
      on default, 'rm -rf /etc/puppetlabs/puppet/ssl'
    end

    # puppetserver won't start with low memory
    memoryfree_mb = fact('memoryfree_mb').to_i
    raise 'At least 256MB free memory required' if memoryfree_mb < 256
  end

  case fact('osfamily')
  when 'Debian'
    from_version = "6.7.0-1#{fact('lsbdistcodename')}"
    to_version = "6.7.2-1#{fact('lsbdistcodename')}"
  else
    from_version = '6.7.0'
    to_version = '6.7.2'
  end

  context 'install 6.7.0' do
    let(:pp) do
      <<-EOS
      class { '::puppet':
        server                => true,
        server_foreman        => false,
        server_reports        => 'store',
        server_external_nodes => '',
        server_version        => '#{from_version}',
        # only for install test - don't think to use this in production!
        # https://docs.puppet.com/puppetserver/latest/tuning_guide.html
        server_jvm_max_heap_size => '256m',
        server_jvm_min_heap_size => '256m',
      }
      EOS
    end

    it_behaves_like 'a idempotent resource'

    describe command('puppetserver --version') do
      its(:stdout) { is_expected.to match("puppetserver version: 6.7.0\n") }
    end

    describe service('puppetserver') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port('8140') do
      it { is_expected.to be_listening }
    end
  end

  context 'upgrade to 6.7.2' do
    let(:pp) do
      <<-EOS
      class { '::puppet':
        server                => true,
        server_foreman        => false,
        server_reports        => 'store',
        server_external_nodes => '',
        server_version        => '#{to_version}',
        # only for install test - don't think to use this in production!
        # https://docs.puppet.com/puppetserver/latest/tuning_guide.html
        server_jvm_max_heap_size => '256m',
        server_jvm_min_heap_size => '256m',
      }
      EOS
    end

    it_behaves_like 'a idempotent resource'

    describe command('puppetserver --version') do
      its(:stdout) { is_expected.to match("puppetserver version: 6.7.2\n") }
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
