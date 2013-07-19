require 'spec_helper'

describe 'puppet::server::config' do
  let :facts do
    {
      :osfamily   => 'RedHat',
      :fqdn       => 'puppetmaster.example.com',
      :clientcert => 'puppetmaster.example.com',
    }
  end

  describe 'with no custom parameters' do
    let :pre_condition do
      "include puppet
      class {'puppet::server':}"
    end

    it 'should set up SSL permissions' do
      should contain_file('/var/lib/puppet/ssl/private_keys').with({
        :group => 'puppet',
        :mode  => '0750',
      })

      should contain_file("/var/lib/puppet/ssl/private_keys/#{facts[:fqdn]}.pem").with({
        :group => 'puppet',
        :mode  => '0640',
      })

      should contain_exec('puppet_server_config-create_ssl_dir').with({
        :creates => '/var/lib/puppet/ssl',
        :command => '/bin/mkdir -p /var/lib/puppet/ssl',
        :before  => 'Exec[puppet_server_config-generate_ca_cert]',
      })

      should contain_exec('puppet_server_config-generate_ca_cert').with({
        :creates => "/var/lib/puppet/ssl/certs/#{facts[:fqdn]}.pem",
        :command => "/usr/sbin/puppetca --generate #{facts[:fqdn]}",
        :require => 'File[/etc/puppet/puppet.conf]',
        :notify  => 'Service[httpd]',
      })
    end

    it 'should set up the ENC' do
      should contain_class('foreman::puppetmaster').with({
        :foreman_url    => "https://#{facts[:fqdn]}",
        :facts          => true,
        :puppet_home    => '/var/lib/puppet',
        :puppet_basedir => '/usr/lib/ruby/site_ruby//puppet',
      })
    end

    it 'should set up the environments' do
      should contain_file('/etc/puppet/environments').with_ensure('directory')
      should contain_file('/usr/share/puppet').with_ensure('directory')
      should contain_file('/etc/puppet/environments/common').with_ensure('directory')
      should contain_file('/usr/share/puppet/modules').with_ensure('directory')

      should contain_file('/etc/puppet/manifests/site.pp').with({
        :ensure  => 'present',
        :replace => false,
        :content => "# Empty site.pp required (puppet #15106, foreman #1708)\n",
      })

      should contain_puppet__server__env('production')
    end
  end

end
