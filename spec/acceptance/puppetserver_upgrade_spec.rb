require 'spec_helper_acceptance'

unless unsupported_puppetserver
  describe 'Scenario: minor version upgrade' do
    before(:all) do
      if check_for_package(default, 'puppetserver')
        on default, 'puppet resource package puppetserver ensure=purged'
        on default, 'rm -rf /etc/sysconfig/puppetserver /etc/puppetlabs/puppetserver'
        on default, 'rm -rf /etc/puppetlabs/puppet/ssl'
      end

      # puppetserver won't start with low memory
      memoryfree_mb = fact('memoryfree_mb').to_i
      raise 'At least 256MB free memory required' if memoryfree_mb < 256
    end

    case ENV['BEAKER_PUPPET_COLLECTION']
    when 'puppet7'
      from_version =
        if fact('os.family') == 'RedHat' && fact('os.release.major') == '9'
          '7.13.0'
        else
          '7.6.0'
        end
      to_version = '7.13.0'
    else
      raise 'Unsupported Puppet collection'
    end

    case fact('osfamily')
    when 'Debian'
      from_version_exact = "#{from_version}-1#{fact('os.distro.codename')}"
      to_version_exact = "#{to_version}-1#{fact('os.distro.codename')}"
    else
      from_version_exact = from_version
      to_version_exact = to_version
    end

    context "install #{from_version}" do
      it_behaves_like 'an idempotent resource' do
        let(:manifest) do
          <<-EOS
          class { 'puppet':
            server         => true,
            server_version => '#{from_version_exact}',
          }
          EOS
        end
      end

      describe command('puppetserver --version') do
        its(:stdout) { is_expected.to match("puppetserver version: #{from_version}\n") }
      end

      describe service('puppetserver') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe port('8140') do
        it { is_expected.to be_listening }
      end
    end

    context "upgrade to #{to_version}" do
      it_behaves_like 'an idempotent resource' do
        let(:manifest) do
          <<-EOS
          class { 'puppet':
            server         => true,
            server_version => '#{to_version_exact}',
          }
          EOS
        end
      end

      describe command('puppetserver --version') do
        its(:stdout) { is_expected.to match("puppetserver version: #{to_version}\n") }
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
end
