require 'spec_helper'

describe 'puppet::config' do
  on_supported_os.each do |os, os_facts|
    next if only_test_os() and not only_test_os.include?(os)
    next if exclude_test_os() and exclude_test_os.include?(os)
    context "on #{os}" do
      let (:default_facts) do
        os_facts.merge({
          :concat_basedir         => '/foo/bar',
          :domain                 => 'example.org',
          :fqdn                   => 'host.example.com',
          :puppetversion          => Puppet.version,
      }) end

      if Puppet.version < '4.0'
        codedir = '/etc/puppet'
        confdir = '/etc/puppet'
        logdir  = '/var/log/puppet'
        rundir  = '/var/run/puppet'
        ssldir  = '/var/lib/puppet/ssl'
        vardir  = '/var/lib/puppet'
        sharedir = '/usr/share/puppet'
        hiera_config = '$confdir/hiera.yaml'
        additional_facts = {}
      else
        codedir = '/etc/puppetlabs/code'
        confdir = '/etc/puppetlabs/puppet'
        logdir  = '/var/log/puppetlabs/puppet'
        rundir  = '/var/run/puppetlabs'
        ssldir  = '/etc/puppetlabs/puppet/ssl'
        vardir  = '/opt/puppetlabs/puppet/cache'
        sharedir = '/opt/puppetlabs/puppet'
        hiera_config = '$codedir/hiera.yaml'
        additional_facts = {:rubysitedir => '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0'}
      end

      if os_facts[:osfamily] == 'FreeBSD'
        codedir = '/usr/local/etc/puppet'
        confdir = '/usr/local/etc/puppet'
        logdir  = '/var/log/puppet'
        rundir  = '/var/run/puppet'
        ssldir  = '/var/puppet/ssl'
        vardir  = '/var/puppet'
        sharedir = '/usr/local/share/puppet'
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
            '    autosign       = $confdir/autosign.conf { mode = 664 }',
            '    show_diff     = false',
            "    hiera_config = #{hiera_config}",
          ]
          if Puppet.version >= '3.6'
              concat_fragment_content.concat([
                "    environmentpath  = #{codedir}/environments",
                "    basemodulepath   = #{codedir}/environments/common:#{codedir}/modules:#{sharedir}/modules",
              ])
          end
          verify_concat_fragment_exact_contents(catalogue, 'puppet.conf+10-main', concat_fragment_content)
        end
      end

      describe 'with server_default_manifest => true and undef content' do
        let :pre_condition do
          'class { "::puppet": server_default_manifest => true }'
        end

        it 'should contain default_manifest setting in puppet.conf' do
          should contain_concat__fragment('puppet.conf+10-main').with_content(/\s+default_manifest = \/etc\/puppet\/manifests\/default_manifest\.pp$/)
        end

        it 'should_not contain default manifest /etc/puppet/manifests/default_manifest.pp' do
          should_not contain_file('/etc/puppet/manifests/default_manifest.pp')
        end
      end

      describe 'with server_default_manifest => true and server_default_manifest_content => "include foo"' do
        let :pre_condition do
          'class { "::puppet": server_default_manifest => true, server_default_manifest_content => "include foo" }'
        end

        it 'should contain default_manifest setting in puppet.conf' do
          should contain_concat__fragment('puppet.conf+10-main').with_content(/\s+default_manifest = \/etc\/puppet\/manifests\/default_manifest\.pp$/)
        end

        it 'should contain default manifest /etc/puppet/manifests/default_manifest.pp' do
          should contain_file('/etc/puppet/manifests/default_manifest.pp').with_content(/include foo/)
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

      describe "when autosign => true" do
        let :pre_condition do
          'class { "::puppet": autosign => true }'
        end

        it 'should contain puppet.conf [main] with autosign = true' do
          verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
            '[main]',
            '    autosign       = true',
          ])
        end
      end

      describe 'when autosign => $confdir/custom_autosign {mode = 664}' do
        let :pre_condition do
          %q{class { "::puppet": autosign => '$confdir/custom_autosign {mode = 664}'}}
        end

        it 'should contain puppet.conf [main] with autosign = $confdir/custom_autosign {mode = 664}' do
          verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
            '[main]',
            '    autosign       = $confdir/custom_autosign {mode = 664}',
          ])
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

      describe "when hiera_config => '$confdir/hiera.yaml'" do
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

  context "on a Windows family OS" do
    let :facts do {
      :concat_basedir => 'C:\Temp',
      :osfamily => 'windows',
      :domain   => 'example.org',
      :puppetversion => Puppet.version,
    } end

    if Puppet.version < '4.0'
      hiera_config = '$confdir/hiera.yaml'
    else
      hiera_config = '$codedir/hiera.yaml'
    end

    describe 'with default parameters' do
      let :pre_condition do
        'include ::puppet'
      end

      it 'should contain auth.conf' do
        should contain_file('C:/ProgramData/PuppetLabs/puppet/etc/auth.conf').with_content(%r{^path /certificate_revocation_list/ca\nmethod find$})
      end

      it 'should_not contain default_manifest setting in puppet.conf' do
        should_not contain_concat__fragment('puppet.conf+10-main').with_content(/default_manifest = .*/)
      end

      it 'should_not contain default manifest /etc/puppet/manifests/default_manifest.pp' do
        should_not contain_file('/etc/puppet/manifests/default_manifest.pp')
      end

      it 'should contain puppet.conf [main]' do
        concat_fragment_content = [
          '[main]',
          '    vardir = C:/ProgramData/PuppetLabs/puppet/var',
          '    logdir = C:/ProgramData/PuppetLabs/puppet/var/log',
          '    rundir = C:/ProgramData/PuppetLabs/puppet/var/run',
          '    ssldir = C:/ProgramData/PuppetLabs/puppet/etc/ssl',
          '    privatekeydir = $ssldir/private_keys { group = service }',
          '    hostprivkey = $privatekeydir/$certname.pem { mode = 640 }',
          '    autosign       = $confdir/autosign.conf { mode = 664 }',
          '    show_diff     = false',
          "    hiera_config = #{hiera_config}",
        ]
        if Puppet.version >= '3.6'
          concat_fragment_content.concat([
            '    environmentpath  = C:/ProgramData/PuppetLabs/puppet/etc/environments',
            '    basemodulepath   = C:/ProgramData/PuppetLabs/puppet/etc/environments/common:C:/ProgramData/PuppetLabs/puppet/etc/modules:C:/ProgramData/PuppetLabs/puppet/share/modules',
          ])
        end
        verify_concat_fragment_exact_contents(catalogue, 'puppet.conf+10-main', concat_fragment_content)
      end

      describe 'with server_default_manifest => true and undef content' do
        let :pre_condition do
          'class { "::puppet": server_default_manifest => true }'
        end

        it 'should contain default_manifest setting in puppet.conf' do
          should contain_concat__fragment('puppet.conf+10-main').with_content(/\s+default_manifest = \/etc\/puppet\/manifests\/default_manifest\.pp$/)
        end

        it 'should_not contain default manifest /etc/puppet/manifests/default_manifest.pp' do
          should_not contain_file('/etc/puppet/manifests/default_manifest.pp')
        end
      end

      describe 'with server_default_manifest => true and server_default_manifest_content => "include foo"' do
        let :pre_condition do
          'class { "::puppet": server_default_manifest => true, server_default_manifest_content => "include foo" }'
        end

        it 'should contain default_manifest setting in puppet.conf' do
          should contain_concat__fragment('puppet.conf+10-main').with_content(/\s+default_manifest = \/etc\/puppet\/manifests\/default_manifest\.pp$/)
        end

        it 'should contain default manifest /etc/puppet/manifests/default_manifest.pp' do
          should contain_file('/etc/puppet/manifests/default_manifest.pp').with_content(/include foo/)
        end
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

    context "when autosign => true" do
      let :pre_condition do
        'class { "::puppet": autosign => true }'
      end

      it 'should contain puppet.conf [main] with autosign = true' do
        verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    autosign       = true',
        ])
      end
    end

    context 'when autosign => $confdir/custom_autosign {mode = 664}' do
      let :pre_condition do
        %q{class { "::puppet": autosign => '$confdir/custom_autosign {mode = 664}'}}
      end

      it 'should contain puppet.conf [main] with autosign = $confdir/custom_autosign {mode = 664}' do
        verify_concat_fragment_contents(catalogue, 'puppet.conf+10-main', [
          '[main]',
          '    autosign       = $confdir/custom_autosign {mode = 664}',
        ])
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
        :concat_basedir => 'C:\Temp',
        :osfamily => 'windows',
        :fqdn     => 'me.example.org',
        :puppetversion => Puppet.version,
      } end

      it 'should contain auth.conf with auth any' do
        should contain_file('C:/ProgramData/PuppetLabs/puppet/etc/auth.conf').with_content(%r{^path /run\nauth any\nmethod save\nallow me.example.org$})
        end
      end
  end

end
