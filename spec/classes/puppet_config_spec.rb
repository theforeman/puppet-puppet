require 'spec_helper'

describe 'puppet::config' do
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
      verify_concat_fragment_exact_contents(subject, 'puppet.conf+10-main', [
        '[main]',
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
      verify_concat_fragment_contents(subject, 'puppet.conf+10-main', [
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
      verify_concat_fragment_contents(subject, 'puppet.conf+10-main', [
        '[main]',
        '    syslogfacility = local6',
      ])
    end
  end

  context "when hiera_config => '$confdir/hiera.yaml'" do
    let :pre_condition do
      "class { 'puppet': hiera_config => '/etc/puppet/hiera/production/hiera.yaml' }"
    end

    it 'should contain puppet.conf [main] with non-default hiera_config' do
      verify_concat_fragment_contents(subject, 'puppet.conf+10-main', [
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
      verify_concat_fragment_contents(subject, 'puppet.conf+10-main', [
        '[main]',
        '    use_srv_records = true',
        '    srv_domain = example.org',
        '    pluginsource = puppet:///plugins',
      ])
    end
  end

end
