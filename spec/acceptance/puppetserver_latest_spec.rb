require 'spec_helper_acceptance'

describe 'Scenario: install puppetserver (latest):', unless: unsupported_puppetserver do
  before(:all) do
    if check_for_package(default, 'puppetserver')
      on default, 'puppet resource package puppetserver ensure=purged'
      on default, 'rm -rf /etc/sysconfig/puppetserver /etc/puppetlabs/puppetserver'
      on default, 'find /etc/puppetlabs/puppet/ssl/ -type f -delete'
    end

    # puppetserver won't start with lower than 2GB memory
    memoryfree_mb = fact('memoryfree_mb').to_i
    raise 'At least 2048MB free memory required' if memoryfree_mb < 256
  end

  context 'default options' do
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

  if ENV['BEAKER_PUPPET_COLLECTION'] != 'puppet7' && fact('os.family') == 'RedHat'
    describe 'JRE version' do
      it { expect(package('java-17-openjdk-headless')).to be_installed }
      it { expect(package('java-11-openjdk-headless')).not_to be_installed }
      it { expect(file('/etc/sysconfig/puppetserver')).to be_file.and(have_attributes(content: include('JAVA_BIN=/usr/lib/jvm/jre-17/bin/java'))) }
    end
  end

  # This is broken on Ubuntu Focal
  # https://github.com/theforeman/puppet-puppet/issues/832
  describe 'server_max_open_files', unless: unsupported_puppetserver || fact('os.release.major') == '20.04' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-MANIFEST
        class { 'puppet':
          server                => true,
          server_max_open_files => 32143,
        }
        MANIFEST
      end
    end

    # pgrep -f java.*puppetserver would be better. But i cannot get it to work. Shellwords.escape() seems to break something
    describe command("grep '^Max open files' /proc/`cat /var/run/puppetlabs/puppetserver/puppetserver.pid`/limits"), :sudo => true do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{^Max open files\s+32143\s+32143\s+files\s*$} }
    end
  end
end
