require 'spec_helper'

describe 'puppet::config' do

  context "on a RedHat family OS" do
    let :facts do {
      :osfamily => 'RedHat',
      :domain   => 'example.org',
    } end

    describe 'with default parameters' do
      let :pre_condition do
        'include ::puppet'
      end

      it 'should contain auth.conf' do
        should contain_file('/etc/puppet/auth.conf').with_content(%r{^path /certificate_revocation_list/ca\nmethod find$})
      end

      it 'should contain puppet.conf [main]' do
        verify_concat_fragment_exact_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    vardir = /var/lib/puppet',
          '    logdir = /var/log/puppet',
          '    rundir = /var/run/puppet',
          '    ssldir = $vardir/ssl',
          '    privatekeydir = $ssldir/private_keys { group = service }',
          '    hostprivkey = $privatekeydir/$certname.pem { mode = 640 }',
          '    autosign       = $confdir/autosign.conf { mode = 664 }',
          '    show_diff     = false',
          '    hiera_config = $confdir/hiera.yaml'
        ])
      end
    end

    describe 'with allow_any_crl_auth' do
      let :pre_condition do
        'class {"::puppet": allow_any_crl_auth => true}'
      end

      it 'should contain auth.conf with auth any' do
        should contain_file('/etc/puppet/auth.conf').with_content(%r{^path /certificate_revocation_list/ca\nauth any$})
      end
    end

    describe 'with auth_allowed' do
      let :pre_condition do
        'class {"::puppet": auth_allowed => [\'$1\', \'puppetproxy\']}'
      end

      it 'should contain auth.conf with allow' do
        should contain_file('/etc/puppet/auth.conf').with_content(%r{^allow \$1, puppetproxy$})
      end
    end

    context "when dns_alt_names => ['foo','bar']" do
      let :pre_condition do
        "class { 'puppet': dns_alt_names => ['foo','bar'] }"
      end

      it 'should contain puppet.conf [main] with dns_alt_names' do
        verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    dns_alt_names = foo,bar',
        ])
      end
    end

    context "when syslogfacility => 'local6'" do
      let :pre_condition do
        "class { 'puppet': syslogfacility => 'local6' }"
      end

      it 'should contain puppet.conf [main] with syslogfacility' do
        verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    syslogfacility = local6',
        ])
      end
    end

    context "when module_repository => 'https://myforgeapi.example.com'" do
      let :pre_condition do
        "class { 'puppet': module_repository => 'https://myforgeapi.example.com' }"
      end

      it 'should contain puppet.conf [main] with module_repository' do
        verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    module_repository = https://myforgeapi.example.com',
        ])
      end
    end

    context "when hiera_config => '$confdir/hiera.yaml'" do
      let :pre_condition do
        "class { 'puppet': hiera_config => '/etc/puppet/hiera/production/hiera.yaml' }"
      end

      it 'should contain puppet.conf [main] with non-default hiera_config' do
        verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    hiera_config = /etc/puppet/hiera/production/hiera.yaml',
        ])
      end
    end

    context "when use_srv_records => true" do
      let :pre_condition do
        "class { 'puppet': use_srv_records => true }"
      end

      it 'should contain puppet.conf [main] with SRV settings' do
        verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    use_srv_records = true',
          '    srv_domain = example.org',
          '    pluginsource = puppet:///plugins',
        ])
      end
    end

    describe 'when listen and listen_to has values' do
      let :pre_condition do
        'class {"::puppet": listen => true, listen_to => ["node1.example.com","node2.example.com",],}'
      end

      it 'should contain auth.conf with auth any' do
        should contain_file('/etc/puppet/auth.conf').with_content(%r{^path /run\nauth any\nmethod save\nallow node1.example.com,node2.example.com$})
      end
    end

    describe 'when listen and puppetmaster has value' do
      let :pre_condition do
        'class {"::puppet": listen => true, puppetmaster => "master.example.com",}'
      end

      it 'should contain auth.conf with auth any' do
        should contain_file('/etc/puppet/auth.conf').with_content(%r{^path /run\nauth any\nmethod save\nallow master.example.com$})
      end
    end

    describe 'when listen => true and default value is used' do
      let :pre_condition do
        'class {"::puppet": listen => true}'
      end
      let :facts do {
        :osfamily => 'RedHat',
        :fqdn => 'me.example.org',
        } end

      it 'should contain auth.conf with auth any' do
        should contain_file('/etc/puppet/auth.conf').with_content(%r{^path /run\nauth any\nmethod save\nallow me.example.org$})
        end
      end

    describe 'with additional settings' do
      let :pre_condition do
        "class {'puppet':
            additional_settings => {disable_warnings => deprecations},
         }"
      end

      it 'should configure puppet.conf' do
        should contain_concat_fragment('puppet.conf+10-main').
          with_content(/^\s+disable_warnings\s+= deprecations$/).
          with({}) # So we can use a trailing dot on each with_content line
      end
    end
  end

  context "on a FreeBSD family OS" do
    let :facts do {
      :osfamily => 'FreeBSD',
      :domain   => 'example.org',
    } end

    describe 'with default parameters' do
      let :pre_condition do
        'include ::puppet'
      end

      it 'should contain auth.conf' do
        should contain_file('/usr/local/etc/puppet/auth.conf').with_content(%r{^path /certificate_revocation_list/ca\nmethod find$})
      end

      it 'should contain puppet.conf [main]' do
        verify_concat_fragment_exact_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    vardir = /var/puppet',
          '    logdir = /var/log/puppet',
          '    rundir = /var/run/puppet',
          '    ssldir = $vardir/ssl',
          '    privatekeydir = $ssldir/private_keys { group = service }',
          '    hostprivkey = $privatekeydir/$certname.pem { mode = 640 }',
          '    autosign       = $confdir/autosign.conf { mode = 664 }',
          '    show_diff     = false',
          '    hiera_config = $confdir/hiera.yaml'
        ])
      end
    end
  end

  context "on a Windows family OS" do
    let :facts do {
      :osfamily => 'windows',
      :domain   => 'example.org',
    } end

    describe 'with default parameters' do
      let :pre_condition do
        'include ::puppet'
      end

      it 'should contain auth.conf' do
        should contain_file('C:/ProgramData/PuppetLabs/puppet/etc/auth.conf').with_content(%r{^path /certificate_revocation_list/ca\nmethod find$})
      end

      it 'should contain puppet.conf [main]' do
        verify_concat_fragment_exact_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    vardir = C:/ProgramData/PuppetLabs/puppet/var',
          '    logdir = C:/ProgramData/PuppetLabs/puppet/var/log',
          '    rundir = C:/ProgramData/PuppetLabs/puppet/var/run',
          '    ssldir = $confdir/ssl',
          '    privatekeydir = $ssldir/private_keys { group = service }',
          '    hostprivkey = $privatekeydir/$certname.pem { mode = 640 }',
          '    autosign       = $confdir/autosign.conf { mode = 664 }',
          '    show_diff     = false',
          '    hiera_config = $confdir/hiera.yaml'
        ])
      end
    end

    describe 'with allow_any_crl_auth' do
      let :pre_condition do
        'class {"::puppet": allow_any_crl_auth => true}'
      end

      it 'should contain auth.conf with auth any' do
        should contain_file('C:/ProgramData/PuppetLabs/puppet/etc/auth.conf').with_content(%r{^path /certificate_revocation_list/ca\nauth any$})
      end
    end

    describe 'with auth_allowed' do
      let :pre_condition do
        'class {"::puppet": auth_allowed => [\'$1\', \'puppetproxy\']}'
      end

      it 'should contain auth.conf with allow' do
        should contain_file('C:/ProgramData/PuppetLabs/puppet/etc/auth.conf').with_content(%r{^allow \$1, puppetproxy$})
      end
    end

    context "when hiera_config => '$confdir/hiera.yaml'" do
      let :pre_condition do
        "class { 'puppet': hiera_config => 'C:/ProgramData/PuppetLabs/hiera/etc/production/hiera.yaml' }"
      end

      it 'should contain puppet.conf [main] with non-default hiera_config' do
        verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    hiera_config = C:/ProgramData/PuppetLabs/hiera/etc/production/hiera.yaml',
        ])
      end
    end

    describe 'when listen and listen_to has values' do
      let :pre_condition do
        'class {"::puppet": listen => true, listen_to => ["node1.example.com","node2.example.com",],}'
      end

      it 'should contain auth.conf with auth any' do
        should contain_file('C:/ProgramData/PuppetLabs/puppet/etc/auth.conf').with_content(%r{^path /run\nauth any\nmethod save\nallow node1.example.com,node2.example.com$})
      end
    end

    describe 'when listen and puppetmaster has value' do
      let :pre_condition do
        'class {"::puppet": listen => true, puppetmaster => "master.example.com",}'
      end

      it 'should contain auth.conf with auth any' do
        should contain_file('C:/ProgramData/PuppetLabs/puppet/etc/auth.conf').with_content(%r{^path /run\nauth any\nmethod save\nallow master.example.com$})
      end
    end

    describe 'when listen => true and default value is used' do
      let :pre_condition do
        'class {"::puppet": listen => true}'
      end
      let :facts do {
        :osfamily => 'windows',
        :fqdn     => 'me.example.org',
      } end

      it 'should contain auth.conf with auth any' do
        should contain_file('C:/ProgramData/PuppetLabs/puppet/etc/auth.conf').with_content(%r{^path /run\nauth any\nmethod save\nallow me.example.org$})
        end
      end
  end

end
