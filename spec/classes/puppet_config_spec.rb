require 'spec_helper'

describe 'puppet::config' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :concat_basedir => '/foo/bar',
          :domain         => 'example.org',
          :fqdn           => 'host.example.com',
          :puppetversion  => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        codedir          = '/etc/puppet'
        confdir          = '/etc/puppet'
        logdir           = '/var/log/puppet'
        rundir           = '/var/run/puppet'
        ssldir           = '/var/lib/puppet/ssl'
        vardir           = '/var/lib/puppet'
        sharedir         = '/usr/share/puppet'
        additional_facts = {}
      else
        codedir          = '/etc/puppetlabs/code'
        confdir          = '/etc/puppetlabs/puppet'
        logdir           = '/var/log/puppetlabs/puppet'
        rundir           = '/var/run/puppetlabs'
        ssldir           = '/etc/puppetlabs/puppet/ssl'
        vardir           = '/opt/puppetlabs/puppet/cache'
        sharedir         = '/opt/puppetlabs/puppet'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      case os_facts[:osfamily]
      when 'FreeBSD'
        codedir  = '/usr/local/etc/puppet'
        confdir  = '/usr/local/etc/puppet'
        logdir   = '/var/log/puppet'
        rundir   = '/var/run/puppet'
        ssldir   = '/var/puppet/ssl'
        vardir   = '/var/puppet'
        sharedir = '/usr/local/share/puppet'
      when 'windows'
        codedir  = 'C:/ProgramData/PuppetLabs/puppet/etc'
        confdir  = 'C:/ProgramData/PuppetLabs/puppet/etc'
        logdir   = 'C:/ProgramData/PuppetLabs/puppet/var/log'
        rundir   = 'C:/ProgramData/PuppetLabs/puppet/var/run'
        ssldir   = 'C:/ProgramData/PuppetLabs/puppet/etc/ssl'
        vardir   = 'C:/ProgramData/PuppetLabs/puppet/var'
        sharedir = 'C:/ProgramData/PuppetLabs/puppet/share'
      end

      let :facts do
        default_facts.merge(additional_facts)
      end

      describe 'with default parameters' do
        let :pre_condition do
          'include ::puppet'
        end

        it 'should contain auth.conf' do
          should contain_file("#{confdir}/auth.conf").with_content(%r{^path /certificate_revocation_list/ca\nmethod find$})
        end

        it 'should_not contain default_manifest setting in puppet.conf' do
          should_not contain_concat__fragment('puppet.conf+10-main').with_content(/\s+default_manifest = .*/)
        end

        it 'should_not contain default manifest /etc/puppet/manifests/default_manifest.pp' do
          should_not contain_file('/etc/puppet/manifests/default_manifest.pp')
        end

        it 'should_not contain reports setting in puppet.conf' do
          should_not contain_concat__fragment('puppet.conf+10-main').with_content(/\s+reports = .*/)
        end

        it 'should contain puppet.conf [main]' do
          concat_fragment_content = [
            '[main]',
            "    vardir = #{vardir}",
            "    logdir = #{logdir}",
            "    rundir = #{rundir}",
            "    ssldir = #{ssldir}",
            '    privatekeydir = $ssldir/private_keys { group = service }',
            '    hostprivkey = $privatekeydir/$certname.pem { mode = 640 }',
            '    show_diff     = false',
          ]
          verify_concat_fragment_exact_contents(catalogue, 'puppet.conf+10-main', concat_fragment_content)
        end
      end

      describe 'with allow_any_crl_auth' do
        let :pre_condition do
          'class {"::puppet": allow_any_crl_auth => true}'
        end

        it 'should contain auth.conf with auth any' do
          should contain_file("#{confdir}/auth.conf").with_content(%r{^path /certificate_revocation_list/ca\nauth any$})
        end
      end

      describe 'with auth_allowed' do
        let :pre_condition do
          'class {"::puppet": auth_allowed => [\'$1\', \'puppetproxy\']}'
        end

        it 'should contain auth.conf with allow' do
          should contain_file("#{confdir}/auth.conf").with_content(%r{^allow \$1, puppetproxy$})
        end
      end

      describe "when dns_alt_names => ['foo','bar']" do
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

      describe "when syslogfacility => 'local6'" do
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

      describe "when module_repository => 'https://myforgeapi.example.com'" do
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

      describe "when use_srv_records => true" do
        let :pre_condition do
          "class { 'puppet': use_srv_records => true }"
        end

        it 'should contain puppet.conf [main] with SRV settings' do
          verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
            '[main]',
            '    use_srv_records = true',
            '    srv_domain = example.org',
            '    pluginsource = puppet:///plugins',
            '    pluginfactsource = puppet:///pluginfacts',
          ])
        end
      end

      describe 'when listen and listen_to has values' do
        let :pre_condition do
          'class {"::puppet": listen => true, listen_to => ["node1.example.com","node2.example.com",],}'
        end

        it 'should contain auth.conf with auth any' do
          should contain_file("#{confdir}/auth.conf").with_content(%r{^path /run\nauth any\nmethod save\nallow node1.example.com,node2.example.com$})
        end
      end

      describe 'when listen and puppetmaster has value' do
        let :pre_condition do
          'class {"::puppet": listen => true, puppetmaster => "master.example.com",}'
        end

        it 'should contain auth.conf with auth any' do
          should contain_file("#{confdir}/auth.conf").with_content(%r{^path /run\nauth any\nmethod save\nallow master.example.com$})
        end
      end

      describe 'when listen => true and default value is used' do
        let :pre_condition do
          'class {"::puppet": listen => true}'
        end

        it 'should contain auth.conf with auth any' do
          should contain_file("#{confdir}/auth.conf").with_content(%r{^path /run\nauth any\nmethod save\nallow #{facts[:fqdn]}$})
        end
      end

      describe 'with additional settings' do
        let :pre_condition do
          "class {'puppet':
              additional_settings => {disable_warnings => deprecations},
           }"
        end

        it 'should configure puppet.conf' do
          should contain_concat__fragment('puppet.conf+10-main').
            with_content(/^\s+disable_warnings\s+= deprecations$/).
            with({}) # So we can use a trailing dot on each with_content line
        end
      end
    end
  end
end
