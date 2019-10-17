#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'etc'
require 'json'
require 'yaml'

begin
  require_relative '../../ruby_task_helper/files/task_helper.rb'
rescue LoadError
  require_relative '../spec/fixtures/modules/ruby_task_helper/files/task_helper.rb'
end

class RunAgentTask < TaskHelper
  def task(puppet_bin: '/opt/puppetlabs/bin/puppet', wait_time: 300, puppet_settings: {}, _noop: false, **_kwargs)
    @puppet_bin = puppet_bin

    validate_puppet_settings(puppet_settings)

    puppet_opts = {
      onetime: true,
      verbose: true,
      daemonize: false,
      usecacheonfailure: false,
      'detailed-exitcodes': true,
      splay: false,
      show_diff: true,
      noop: _noop
    }.merge(puppet_settings)

    check_running_as_root
    check_agent_not_disabled
    wait_for_puppet_lockfile(wait_time)
    run_puppet(puppet_opts)
  end

  def validate_puppet_settings(settings)
    if settings.key?(:noop)
      raise TaskHelper::Error.new(
        'Don\'t include `noop` in puppet_settings. Use bolt\'s dedicated `--noop` option instead',
        'theforeman-puppet/invalid_puppet_setting'
      )
    end
    settings.each do |setting, _val|
      next if all_settings.keys.include?(setting)

      raise TaskHelper::Error.new(
        "#{setting} is not a valid puppet setting",
        'theforeman-puppet/invalid_puppet_setting'
      )
    end
    if %i[onetime daemonize].any? { |x| settings.include?(x) }
      raise TaskHelper::Error.new(
        'Overriding `onetime` or `daemonize` is not supported in this task',
        'theforeman-puppet/invalid_puppet_setting'
      )
    end
  end

  def wait_for_puppet_lockfile(wait_time)
    waited = 0
    while agent_locked? && waited < wait_time
      sleep 1
      waited += 1
    end

    if agent_locked?
      raise TaskHelper::Error.new(
        'Lockfile still exists after waiting',
        'theforeman-puppet/lockfile_timeout_expired'
      )
    end

    waited
  end

  def check_agent_not_disabled
    if agent_disabled?
      raise TaskHelper::Error.new(
        'Agent is disabled on this node',
        'theforeman-puppet/agent_disabled',
        disabled_message: disabled_message
      )
    end
  end

  def agent_locked?
    File.exist?(agent_config(:agent_catalog_run_lockfile))
  end

  def agent_disabled?
    File.exist?(agent_config(:agent_disabled_lockfile))
  end

  def disabled_message
    JSON.load(File.read(agent_config(:agent_disabled_lockfile)))['disabled_message']
  end

  def last_run_summary
    YAML.load_file(agent_config(:lastrunfile))
  end

  def agent_config(setting)
    if all_settings[setting].nil?
      raise TaskHelper::Error.new(
        "Couldn't determine #{setting} configuration",
        'theforeman-puppet/config_unknown'
      )
    end
    all_settings[setting]
  end

  def all_settings
    return @all_settings unless @all_settings.nil?

    cmd = [@puppet_bin, 'config', 'print']
    stdout, stderr, status = Open3.capture3(*cmd)

    unless status.exitstatus.zero?
      raise TaskHelper::Error.new(
        'Couldn\'t determine puppet configuration',
        'theforeman-puppet/config_unknown',
        stderr: stderr
      )
    end

    settings = {}
    stdout.split("\n").each do |line|
      k, v = line.split(' = ', 2)
      v = nil if v == ''
      settings[k.to_sym] = v
    end
    @all_settings = settings
    @all_settings
  end

  def check_running_as_root
    unless Process.euid.zero?
      raise TaskHelper::Error.new(
        'Puppet agent needs to run as root',
        'theforeman-puppet/bad_euid',
        euid: Process.euid
      )
    end
  end

  def puppet_cmd(puppet_opts)
    cmd = [@puppet_bin, 'agent']
    puppet_opts.each do |option, value|
      case value
      when true
        cmd << "--#{option}"
      when false
        cmd << "--no-#{option}"
      else
        cmd << "--#{option}"
        cmd << value
      end
    end
    cmd
  end

  def run_puppet(puppet_opts)
    stdout, stderr, status = Open3.capture3(*puppet_cmd(puppet_opts))

    case status.exitstatus
    when 0
      {
        result: 'The run succeeded with no changes or failures; the system was already in the desired state (or --noop was used).',
        stdout: stdout,
        stderr: stderr,
        detailed_exitcode: 0,
        last_run_summary: last_run_summary
      }
    when 1
      raise TaskHelper::Error.new(
        'Puppet run failed',
        'theforeman-puppet/run_failed',
        stderr: stderr,
        stdout: stdout,
        detailed_exitcode: status.exitstatus
      )
    when 2
      {
        result: 'The run succeeded, and some resources were changed.',
        stdout: stdout,
        stderr: stderr,
        detailed_exitcode: 2,
        last_run_summary: last_run_summary
      }
    when 4, 6
      raise TaskHelper::Error.new(
        'Puppet run succeeded, but some resources failed',
        'theforeman-puppet/failed_resources',
        stderr: stderr,
        stdout: stdout,
        detailed_exitcode: status.exitstatus,
        last_run_summary: last_run_summary
      )
    end
  end
end

RunAgentTask.run if $PROGRAM_NAME == __FILE__
