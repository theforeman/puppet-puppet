require 'spec_helper'
require_relative '../../tasks/run_agent.rb'

describe 'RunAgentTask' do
  let(:task) { RunAgentTask.new }

  describe '.task' do
    let(:mock_sucess_result) do
      {
        result: 'The run succeeded with no changes or failures; the system was already in the desired state (or --noop was used).',
        stdout: 'STDOUT',
        stderr: 'STDERR',
        detailed_exitcode: 0,
        last_run_summary: {}
      }
    end

    context 'default options' do
      let(:default_puppet_opts) do
        {
          onetime: true,
          verbose: true,
          daemonize: false,
          usecacheonfailure: false,
          'detailed-exitcodes': true,
          splay: false,
          show_diff: true,
          noop: false
        }
      end
      it 'runs the puppet agent' do
        expect(task).to receive(:validate_puppet_settings).with({})
        expect(task).to receive(:check_running_as_root)
        expect(task).to receive(:check_agent_not_disabled)
        expect(task).to receive(:wait_for_puppet_lockfile)
        expect(task).to receive(:run_puppet).with(default_puppet_opts).and_return(mock_sucess_result)
        expect(task.task).to eq(mock_sucess_result)
      end
    end
    context 'with usecacheonfailure puppet_setting' do
      let(:params) { { puppet_settings: { usecacheonfailure: true } } }
      let(:expected_puppet_opts) do
        {
          onetime: true,
          verbose: true,
          daemonize: false,
          usecacheonfailure: true,
          'detailed-exitcodes': true,
          splay: false,
          show_diff: true,
          noop: false
        }
      end
      it 'runs the puppet agent' do
        expect(task).to receive(:validate_puppet_settings).with(usecacheonfailure: true)
        expect(task).to receive(:check_running_as_root)
        expect(task).to receive(:check_agent_not_disabled)
        expect(task).to receive(:wait_for_puppet_lockfile)
        expect(task).to receive(:run_puppet).with(expected_puppet_opts).and_return(mock_sucess_result)
        expect(task.task(params)).to eq(mock_sucess_result)
      end
    end
  end
  describe '.validate_puppet_settings' do
    let(:mock_all_settings) do
      {
        environment: 'production',
        server: 'puppet.example.com',
        onetime: false,
        daemonize: true
      }
    end

    before do
      allow(task).to receive(:all_settings).and_return(mock_all_settings)
    end
    context 'when user tries to set `noop` in `puppet_settings`' do
      it do
        expect { task.validate_puppet_settings(noop: true) }.to raise_error(TaskHelper::Error, /Don't include `noop` in puppet_settings/)
      end
    end
    context 'when a setting isn\'t a valid puppet configuration setting' do
      it do
        expect { task.validate_puppet_settings(environment: 'dev', not_a_setting: 'foo') }.to raise_error(TaskHelper::Error, /not_a_setting is not a valid puppet setting/)
      end
    end
    context 'when a user tries to set `daemonize` in `puppet_settings`' do
      it do
        expect { task.validate_puppet_settings(environment: 'dev', daemonize: true) }.to raise_error(TaskHelper::Error, /Overriding `onetime` or `daemonize` is not supported in this task/)
      end
    end
    context 'when a user tries to set `onetime` in `puppet_settings`' do
      it do
        expect { task.validate_puppet_settings(environment: 'dev', onetime: false) }.to raise_error(TaskHelper::Error, /Overriding `onetime` or `daemonize` is not supported in this task/)
      end
    end
  end
  describe '.wait_for_puppet_lockfile' do
    context 'with wait_time = 5' do
      context 'when agent isn\'t locked' do
        it do
          allow(task).to receive(:agent_locked?).and_return(false)
          expect(task.wait_for_puppet_lockfile(5)).to eq(0)
        end
      end
      context 'when agent is locked for 2 seconds' do
        it 'waits for 2 seconds' do
          i = 0
          allow(task).to receive(:agent_locked?) do
            if i < 2
              i += 1
              true
            else
              false
            end
          end
          expect(task.wait_for_puppet_lockfile(5)).to eq(2)
        end
      end
      context 'when agent is locked for more than wait_time' do
        it do
          allow(task).to receive(:agent_locked?).and_return(true)
          expect { task.wait_for_puppet_lockfile(5) }.to raise_error(TaskHelper::Error, /Lockfile still exists after waiting/)
        end
      end
    end
  end
  describe '.check_agent_not_disabled' do
    context 'when agent is disabled' do
      it do
        allow(task).to receive(:agent_disabled?).and_return(true)
        allow(task).to receive(:disabled_message).and_return('Example disabled reason')
        expect { task.check_agent_not_disabled }.to raise_error(TaskHelper::Error, /Agent is disabled on this node/)
      end
    end
    context 'when agent isn\'t disabled' do
      it do
        allow(task).to receive(:agent_disabled?).and_return(false)
        expect { task.check_agent_not_disabled }.to_not raise_error
      end
    end
  end
  describe '.agent_locked?' do
    before do
      allow(task).to receive(:agent_config).with(:agent_catalog_run_lockfile).and_return('/path/to/lockfile')
    end
    context 'when not locked' do
      it do
        allow(File).to receive(:exist?).with('/path/to/lockfile').and_return(false)
        expect(task.agent_locked?).to eq(false)
      end
    end
    context 'when locked' do
      it do
        allow(File).to receive(:exist?).with('/path/to/lockfile').and_return(true)
        expect(task.agent_locked?).to eq(true)
      end
    end
  end
  describe '.agent_disabled?' do
    before do
      allow(task).to receive(:agent_config).with(:agent_disabled_lockfile).and_return('/path/to/lockfile')
    end
    context 'when not disabled' do
      it do
        allow(File).to receive(:exist?).with('/path/to/lockfile').and_return(false)
        expect(task.agent_disabled?).to eq(false)
      end
    end
    context 'when disabled' do
      it do
        allow(File).to receive(:exist?).with('/path/to/lockfile').and_return(true)
        expect(task.agent_disabled?).to eq(true)
      end
    end
  end
  describe '.disabled_message' do
    it 'parses agent disabled lockfile' do
      allow(task).to receive(:agent_config).with(:agent_disabled_lockfile).and_return(File.join(File.dirname(__FILE__), '../fixtures/agent_disabled.lock'))
      expect(task.disabled_message).to eq('example disable reason')
    end
  end
  describe '.agent_config' do
    let(:mock_all_settings) do
      {
        environment: 'production',
        server: 'puppet.example.com',
        onetime: false,
        daemonize: true
      }
    end

    before do
      allow(task).to receive(:all_settings).and_return(mock_all_settings)
    end
    context 'when setting exists' do
      it do
        expect(task.agent_config(:environment)).to eq('production')
      end
    end
    context 'when setting doesn\'t exist' do
      it do
        expect { task.agent_config(:foobar) }.to raise_error(TaskHelper::Error, /Couldn't determine foobar configuration/)
      end
    end
  end
  describe '.all_settings' do
    context 'when called more than once' do
      it 'returns a cached hash of settings' do
        task.instance_variable_set(:@all_settings, cached_setting: 'foo')
        expect(task.all_settings).to eq(cached_setting: 'foo')
      end
    end
    context 'when calling puppet fails' do
      it do
        task.instance_variable_set(:@puppet_bin, '/opt/puppetlabs/bin/puppet')
        mock_status = double('mock failed status', exitstatus: 1)
        allow(Open3).to receive(:capture3).with('/opt/puppetlabs/bin/puppet', 'config', 'print').and_return(['STDOUT', 'STDERR', mock_status])
        expect { task.all_settings }.to raise_error(TaskHelper::Error, /Couldn't determine puppet configuration/)
      end
    end
    context 'when puppet returns settings' do
      let(:mock_stdout) do
        <<~MOCK_STDOUT
        runinterval = 1800
        runtimeout = 3600
        serial = /etc/puppet/ssl/ca/serial
        server = puppet
        server_datadir = /opt/puppetlabs/puppet/cache/server_data
        server_list = 
        show_diff = false
        MOCK_STDOUT
      end
      let(:expected_all_settings) do
        {
          runinterval: '1800',
          runtimeout: '3600',
          serial: '/etc/puppet/ssl/ca/serial',
          server: 'puppet',
          server_datadir: '/opt/puppetlabs/puppet/cache/server_data',
          server_list: nil,
          show_diff: 'false'
        }
      end
      it do
        task.instance_variable_set(:@puppet_bin, '/opt/puppetlabs/bin/puppet')
        mock_status = double('mock status', exitstatus: 0)
        allow(Open3).to receive(:capture3).with('/opt/puppetlabs/bin/puppet', 'config', 'print').and_return([mock_stdout, 'STDERR', mock_status])
        expect(task.all_settings).to eq(expected_all_settings)
      end
    end
  end
  describe '.check_running_as_root' do
    context 'when EUID is zero' do
      it do
        allow(Process).to receive(:euid).and_return(0)
        expect { task.check_running_as_root }.to_not raise_error
      end
    end
    context 'when EUID is non-zero' do
      it do
        allow(Process).to receive(:euid).and_return(42)
        expect { task.check_running_as_root }.to raise_error(TaskHelper::Error, /Puppet agent needs to run as root/)
      end
    end
  end
  describe '.last_run_summary' do
    it 'parses last_run_summary.yaml' do
      allow(task).to receive(:agent_config).with(:lastrunfile).and_return(File.join(File.dirname(__FILE__), '../fixtures/last_run_summary.yaml'))
      expect(task.last_run_summary['changes']['total']).to eq(0)
    end
  end
  describe '.puppet_cmd' do
    let(:options) do
      {
        environment: 'test',
        onetime: true,
        verbose: true,
        daemonize: false,
        usecacheonfailure: false,
        'detailed-exitcodes': true,
        splay: false,
        show_diff: true,
        noop: false
      }
    end
    before do
      task.instance_variable_set(:@puppet_bin, '/opt/puppetlabs/bin/puppet')
    end
    it 'adds boolean true options to command with `--`' do
      expect(task.puppet_cmd(options)).to include('--onetime', '--show_diff')
    end
    it 'adds boolean false options to command with `--no-` prefix' do
      expect(task.puppet_cmd(options)).to include('--no-daemonize', '--no-splay')
    end
    it 'adds other options to command with values' do
      expect(task.puppet_cmd(options)).to start_with('/opt/puppetlabs/bin/puppet', 'agent', '--environment', 'test')
    end
  end
  describe '.run_puppet' do
    before do
      mock_cmd = double
      allow(task).to receive(:puppet_cmd).and_return(mock_cmd)
      allow(task).to receive(:last_run_summary).and_return('MOCK SUMMARY')
      allow(Open3).to receive(:capture3).with(mock_cmd).and_return(['STDOUT', 'STDERR', mock_status])
    end
    context 'successful run with no changes' do
      let(:mock_status) do
        double('mock status', exitstatus: 0)
      end
      it do
        expect(task.run_puppet({})).to eq(
          result: 'The run succeeded with no changes or failures; the system was already in the desired state (or --noop was used).',
          stdout: 'STDOUT',
          stderr: 'STDERR',
          detailed_exitcode: 0,
          last_run_summary: 'MOCK SUMMARY'
        )
      end
    end
    context 'successful run with changes' do
      let(:mock_status) do
        double('mock status', exitstatus: 2)
      end
      it do
        expect(task.run_puppet({})).to eq(
          result: 'The run succeeded, and some resources were changed.',
          stdout: 'STDOUT',
          stderr: 'STDERR',
          detailed_exitcode: 2,
          last_run_summary: 'MOCK SUMMARY'
        )
      end
    end
    context 'unsuccessful run' do
      let(:mock_status) do
        double('mock status', exitstatus: 1)
      end
      it { expect { task.run_puppet({}) }.to raise_error(TaskHelper::Error, /Puppet run failed/) }
    end
    context 'run succeeded with resources having errors' do
      context 'without changes' do
        let(:mock_status) do
          double('mock status', exitstatus: 4)
        end
        it { expect { task.run_puppet({}) }.to raise_error(TaskHelper::Error, /Puppet run succeeded, but some resources failed/) }
      end
      context 'with changes' do
        let(:mock_status) do
          double('mock status', exitstatus: 6)
        end
        it { expect { task.run_puppet({}) }.to raise_error(TaskHelper::Error, /Puppet run succeeded, but some resources failed/) }
      end
    end
  end
end
