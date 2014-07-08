require 'spec_helper'

describe 'puppet::config' do
  let :facts do {
    :osfamily => 'RedHat',
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
end
