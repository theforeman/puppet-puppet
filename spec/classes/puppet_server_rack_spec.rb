require 'spec_helper'

describe 'puppet::server::rack' do
  let :facts do {
    :concat_basedir         => '/nonexistant',
    :osfamily               => 'RedHat',
    :operatingsystemrelease => '6.5',
  } end

  describe 'defaults' do
    let :pre_condition do
      "class {'puppet': server => true}"
    end

    it 'should define Exec[puppet_server_rack-restart]' do
      should contain_exec('puppet_server_rack-restart').with({
        :command      => '/bin/touch /etc/puppet/rack/tmp/restart.txt',
        :refreshonly  => true,
        :cwd          => '/etc/puppet/rack',
        :require      => ['Class[Puppet::Server::Install]', 'File[/etc/puppet/rack/tmp]'],
      })
    end

    it 'should create server_app_root' do
      should contain_file('/etc/puppet/rack').with({
        :ensure => 'directory',
        :owner  => 'puppet',
        :mode   => '0755',
      })
    end

    it 'should create server_app_root public' do
      should contain_file('/etc/puppet/rack/public').with({
        :ensure => 'directory',
        :owner  => 'puppet',
        :mode   => '0755',
      })
    end

    it 'should create server_app_root tmp' do
      should contain_file('/etc/puppet/rack/tmp').with({
        :ensure => 'directory',
        :owner  => 'puppet',
        :mode   => '0755',
      })
    end

    it 'should create config.ru' do
      should contain_file('/etc/puppet/rack/config.ru').with({
        :owner  => 'puppet',
        :notify => 'Exec[puppet_server_rack-restart]',
      })
    end

    it 'should manage config.ru contents' do
      verify_exact_contents(catalogue, '/etc/puppet/rack/config.ru', [
        '$0 = "master"',
        'ARGV << "--rack"',
        'ARGV << "--confdir" << "/etc/puppet"',
        'ARGV << "--vardir"  << "/var/lib/puppet"',
        'Encoding.default_external = Encoding::UTF_8 if defined? Encoding',
        'require \'puppet/util/command_line\'',
        'run Puppet::Util::CommandLine.new.execute',
      ])
    end
  end

  describe 'when server_rack_arguments defined' do
    let :pre_condition do
      "class {'puppet': server => true, server_rack_arguments => ['--profile', '--logdest', '/dne/log'] }"
    end

    it 'should set ARGV values' do
      verify_contents(catalogue, '/etc/puppet/rack/config.ru', [
        'ARGV << "--rack"',
        'ARGV << "--confdir" << "/etc/puppet"',
        'ARGV << "--vardir"  << "/var/lib/puppet"',
        'ARGV << "--profile"',
        'ARGV << "--logdest"',
        'ARGV << "/dne/log"',
      ])
    end
  end
end
