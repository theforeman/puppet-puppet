require 'spec_helper_acceptance'

describe 'Scenario: 5.1.3 to 5.3.6 upgrade:', if: ENV['BEAKER_PUPPET_COLLECTION'] == 'puppet5' && fact('lsbdistcodename') != 'bionic' do
  before(:context) do
    if check_for_package(default, 'puppetserver')
      on default, puppet('resource package puppetserver ensure=purged')
      on default, 'rm -rf /etc/sysconfig/puppetserver /etc/puppetlabs/puppetserver'
      on default, 'rm -rf /etc/puppetlabs/puppet/ssl'
    end

    # puppetserver won't start with lower than 2GB memory
    memoryfree_mb = fact('memoryfree_mb').to_i
    raise 'At least 2048MB free memory required' if memoryfree_mb < 256
  end

  case fact('osfamily')
  when 'Debian'
    from_version = "5.1.3-1#{fact('lsbdistcodename')}"
    to_version = "5.3.6-1#{fact('lsbdistcodename')}"
  else
    from_version = '5.1.3'
    to_version = '5.3.6'
  end

  context 'install 5.1.3' do
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
      its(:stdout) { is_expected.to match("puppetserver version: 5.1.3\n") }
    end

    describe service('puppetserver') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port('8140') do
      it { is_expected.to be_listening }
    end
  end

  context 'upgrade to 5.3.6' do
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
      its(:stdout) { is_expected.to match("puppetserver version: 5.3.6\n") }
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
