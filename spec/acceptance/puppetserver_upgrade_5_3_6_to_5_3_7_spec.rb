require 'spec_helper_acceptance'

describe 'Scenario: 5.3.6 to 5.3.7 upgrade:', if: ENV['BEAKER_PUPPET_COLLECTION'] == 'puppet5', unless: unsupported_puppetserver do
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
    from_version = "5.3.6-1#{fact('lsbdistcodename')}"
    to_version = "5.3.7-1#{fact('lsbdistcodename')}"
  else
    from_version = '5.3.6'
    to_version = '5.3.7'
  end

  context 'install 5.3.6' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'puppet':
          server         => true,
          server_version => '#{from_version}',
        }
        EOS
      end
    end

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

  context 'upgrade to 5.3.7' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'puppet':
          server         => true,
          server_version => '#{to_version}',
        }
        EOS
      end
    end

    describe command('puppetserver --version') do
      its(:stdout) { is_expected.to match("puppetserver version: 5.3.7\n") }
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
