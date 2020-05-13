require 'spec_helper_acceptance'

describe 'Puppetserver config options', unless: unsupported_puppetserver do
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

  describe 'server_max_open_files' do
    let(:pp) do
      <<-MANIFEST
      class { '::puppet':
        server                   => true,
        server_foreman           => false,
        server_reports           => 'store',
        server_external_nodes    => '',
        # only for install test - don't think to use this in production!
        # https://docs.puppet.com/puppetserver/latest/tuning_guide.html
        server_jvm_max_heap_size => '256m',
        server_jvm_min_heap_size => '256m',
        server_max_open_files    => 32143,
      }
      MANIFEST
    end

    it_behaves_like 'a idempotent resource'

    # pgrep -f java.*puppetserver would be better. But i cannot get it to work. Shellwords.escape() seems to break something
    describe command("grep '^Max open files' /proc/`cat /var/run/puppetlabs/puppetserver/puppetserver.pid`/limits"), :sudo => true do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{^Max open files\s+32143\s+32143\s+files\s*$} }
    end
  end
end
