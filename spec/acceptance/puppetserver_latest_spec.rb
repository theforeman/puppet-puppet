require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

describe 'Scenario: install puppetserver (latest):' do
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

  let(:pp) do
    <<-EOS
    class { '::puppet':
      server                => true,
      server_foreman        => false,
      server_reports        => 'store',
      server_external_nodes => '',
      # only for install test - don't think to use this in production!
      # https://docs.puppet.com/puppetserver/latest/tuning_guide.html
      server_jvm_max_heap_size    => '256m',
      server_jvm_min_heap_size    => '256m',
      server_max_active_instances => 1,
    }
    EOS
  end

  it_behaves_like 'a idempotent resource'

  describe 'run_agent task' do
    include Beaker::TaskHelper::Inventory
    include BoltSpec::Run

    def bolt_config
      { 'modulepath' => File.join(File.dirname(File.expand_path(__FILE__)), '../', 'fixtures', 'modules') }
    end

    def bolt_inventory
      hosts_to_inventory
    end

    context 'with empty catalog' do
      before do
        sleep 10
      end
      it 'applies and changes nothing' do
        results = run_task('puppet::run_agent', 'agent', {})
        expect(results.first).to include('status' => 'success')
        expect(results.first['result']['detailed_exitcode']).to eq 0
        expect(results.first['result']['last_run_summary']['changes']['total']).to eq 0
      end
    end

    context 'with basic site.pp' do
      before do
        on default, 'mkdir -p /etc/puppetlabs/code/environments/production/manifests'
        on default, 'echo "node default { notify {\'test\':}}" > /etc/puppetlabs/code/environments/production/manifests/site.pp'
      end
      describe 'running task with --noop' do
        it 'changes nothing and reports noop events' do
          results = run_task('puppet::run_agent', 'agent', '_noop' => true)
          expect(results.first).to include('status' => 'success')
          expect(results.first['result']['detailed_exitcode']).to eq 0
          expect(results.first['result']['last_run_summary']['changes']['total']).to eq 0
          expect(results.first['result']['last_run_summary']['events']['noop']).to eq 1
        end
      end
      describe 'running task without --noop' do
        it 'applies changes' do
          results = run_task('puppet::run_agent', 'agent', {})
          expect(results.first).to include('status' => 'success')
          expect(results.first['result']['detailed_exitcode']).to eq 2
          expect(results.first['result']['last_run_summary']['changes']['total']).to eq 1
          expect(results.first['result']['last_run_summary']['events']['success']).to eq 1
        end
      end
    end
    context 'with invalid puppet_settings' do
      it 'returns failure' do
        results = run_task('puppet::run_agent', 'agent', 'puppet_settings' => { 'foo' => 'bar' })
        expect(results.first).to include('status' => 'failure')
      end
    end
    context 'with invalid manifest' do
      before do
        on default, 'echo "NOT A MANIFEST" > /etc/puppetlabs/code/environments/production/manifests/site.pp'
      end
      it 'returns failure' do
        results = run_task('puppet::run_agent', 'agent', {})
        expect(results.first).to include('status' => 'failure')
        expect(results.first['result']['_error']['details']['detailed_exitcode']).to eq 1
      end
    end
    context 'overriding environment' do
      before do
        on default, 'mkdir -p /etc/puppetlabs/code/environments/test/manifests'
        on default, 'echo "node default { file {\'/tmp/overriding_environment_test\': ensure => \'file\'}}" > /etc/puppetlabs/code/environments/test/manifests/site.pp'
      end
      it 'applies changes' do
        results = run_task('puppet::run_agent', 'agent', 'puppet_settings' => { 'environment' => 'test' })
        expect(results.first).to include('status' => 'success')
        expect(results.first['result']['detailed_exitcode']).to eq 2
        expect(results.first['result']['last_run_summary']['changes']['total']).to eq 1
        expect(results.first['result']['last_run_summary']['events']['success']).to eq 1
      end
      it 'is idempotent' do
        results = run_task('puppet::run_agent', 'agent', 'puppet_settings' => { 'environment' => 'test' })
        expect(results.first).to include('status' => 'success')
        expect(results.first['result']['detailed_exitcode']).to eq 0
      end
      describe file('/tmp/overriding_environment_test') do
        it { should exist }
      end
    end
  end
end
