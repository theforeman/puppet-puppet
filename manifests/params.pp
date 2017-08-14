# Default parameters
class puppet::params {

  # Basic config
  $version             = 'present'
  $user                = 'puppet'
  $group               = 'puppet'
  $ip                  = '0.0.0.0'
  $port                = 8140
  $listen              = false
  $listen_to           = []
  $pluginsync          = true
  $splay               = false
  $splaylimit          = '1800'
  $runinterval         = 1800
  $runmode             = 'service'

  # Not defined here as the commands depend on module parameter "dir"
  $cron_cmd            = undef
  $systemd_cmd         = undef

  $agent_noop          = false
  $show_diff           = false
  $module_repository   = undef
  if versioncmp($::puppetversion, '4.0') < 0 or versioncmp($::puppetversion, '4.5') >= 0 {
    $hiera_config            = '$confdir/hiera.yaml'
  } else {
    $hiera_config            = '$codedir/hiera.yaml'
  }
  $usecacheonfailure   = true
  $ca_server           = undef
  $ca_port             = undef
  $ca_crl_filepath     = undef
  $server_crl_enable   = undef
  $prerun_command      = undef
  $postrun_command     = undef
  $dns_alt_names       = []
  $use_srv_records     = false

  if defined('$::domain') {
    $srv_domain = $::domain
  } else {
    $srv_domain = undef
  }

  # lint:ignore:puppet_url_without_modules
  $pluginsource        = 'puppet:///plugins'
  $pluginfactsource    = 'puppet:///pluginfacts'
  # lint:endignore
  $classfile           = '$statedir/classes.txt'
  $syslogfacility      = undef
  $environment         = $::environment

  if versioncmp($::puppetversion, '4.0') < 0 {
    $aio_package      = false
    $deb_naio_package = false
  } elsif $::osfamily == 'Windows' or $::rubysitedir =~ /\/opt\/puppetlabs\/puppet/ {
    $aio_package      = true
    $deb_naio_package = false
  } else {
    $aio_package      = false
    $deb_naio_package = ($::osfamily == 'Debian')
  }

  case $::osfamily {
    'Windows' : {
      # Windows prefixes normal paths with the Data Directory's path and leaves 'puppet' off the end
      $dir_prefix                 = 'C:/ProgramData/PuppetLabs/puppet'
      $dir                        = "${dir_prefix}/etc"
      $codedir                    = "${dir_prefix}/etc"
      $logdir                     = "${dir_prefix}/var/log"
      $rundir                     = "${dir_prefix}/var/run"
      $ssldir                     = "${dir_prefix}/etc/ssl"
      $vardir                     = "${dir_prefix}/var"
      $sharedir                   = "${dir_prefix}/share"
      $bindir                     = "${dir_prefix}/bin"
      $root_group                 = undef
      $server_puppetserver_dir    = undef
      $server_puppetserver_vardir = undef
      $server_puppetserver_rundir = undef
      $server_puppetserver_logdir = undef
      $server_ruby_load_paths     = []
      $server_jruby_gem_home      = undef
    }

    /^(FreeBSD|DragonFly)$/ : {
      $dir                        = '/usr/local/etc/puppet'
      $codedir                    = '/usr/local/etc/puppet'
      $logdir                     = '/var/log/puppet'
      $rundir                     = '/var/run/puppet'
      $ssldir                     = '/var/puppet/ssl'
      $vardir                     = '/var/puppet'
      $sharedir                   = '/usr/local/share/puppet'
      $bindir                     = '/usr/local/bin'
      $root_group                 = undef
      $server_puppetserver_dir    = '/usr/local/etc/puppetserver'
      $server_puppetserver_vardir = '/var/puppet/server/data/puppetserver'
      $server_puppetserver_rundir = '/var/run/puppetserver'
      $server_puppetserver_logdir = '/var/log/puppetserver'
      $ruby_gem_dir               = regsubst($::rubyversion, '^(\d+\.\d+).*$', '/usr/local/lib/ruby/gems/\1/gems')
      $server_ruby_load_paths     = [$::rubysitedir, "${ruby_gem_dir}/facter-${::facterversion}/lib"]
      $server_jruby_gem_home      = '/var/puppet/server/data/puppetserver/jruby-gems'
    }

    'Archlinux' : {
      $dir                        = '/etc/puppetlabs/puppet'
      $codedir                    = '/etc/puppetlabs/code'
      $logdir                     = '/var/log/puppetlabs/puppet'
      $rundir                     = '/var/run/puppetlabs'
      $ssldir                     = '/etc/puppetlabs/puppet/ssl'
      $vardir                     = '/opt/puppetlabs/puppet/cache'
      $sharedir                   = '/opt/puppetlabs/puppet'
      $bindir                     = '/usr/bin'
      $root_group                 = undef
      $server_puppetserver_dir    = undef
      $server_puppetserver_vardir = undef
      $server_puppetserver_rundir = undef
      $server_puppetserver_logdir = undef
      $server_ruby_load_paths     = []
      $server_jruby_gem_home      = undef
    }

    default : {
      if $aio_package {
        $dir                        = '/etc/puppetlabs/puppet'
        $codedir                    = '/etc/puppetlabs/code'
        $logdir                     = '/var/log/puppetlabs/puppet'
        $rundir                     = '/var/run/puppetlabs'
        $ssldir                     = '/etc/puppetlabs/puppet/ssl'
        $vardir                     = '/opt/puppetlabs/puppet/cache'
        $sharedir                   = '/opt/puppetlabs/puppet'
        $bindir                     = '/opt/puppetlabs/bin'
        $server_puppetserver_dir    = '/etc/puppetlabs/puppetserver'
        $server_puppetserver_vardir = '/opt/puppetlabs/server/data/puppetserver'
        $server_puppetserver_rundir = '/var/run/puppetlabs/puppetserver'
        $server_puppetserver_logdir = '/var/log/puppetlabs/puppetserver'
        $server_ruby_load_paths     = ['/opt/puppetlabs/puppet/lib/ruby/vendor_ruby']
        $server_jruby_gem_home      = '/opt/puppetlabs/server/data/puppetserver/jruby-gems'
      } else {
        $dir                        = '/etc/puppet'
        $codedir                    =  $deb_naio_package ? {
          true  => '/etc/puppet/code',
          false => '/etc/puppet',
        }
        $logdir                     = '/var/log/puppet'
        $rundir                     = '/var/run/puppet'
        $ssldir                     = '/var/lib/puppet/ssl'
        $vardir                     = '/var/lib/puppet'
        $sharedir                   = '/usr/share/puppet'
        $bindir                     = '/usr/bin'
        $server_puppetserver_dir    = '/etc/puppetserver'
        $server_puppetserver_vardir = $vardir
        $server_puppetserver_rundir = undef
        $server_puppetserver_logdir = undef
        $server_ruby_load_paths     = []
        $server_jruby_gem_home      = '/var/lib/puppet/jruby-gems'
      }
      $root_group = undef
    }
  }

  if versioncmp($::puppetversion, '4.0') < 0 {
    $configtimeout = 120
  } else {
    $configtimeout = undef
  }

  $autosign         = "${dir}/autosign.conf"
  $autosign_entries = []
  $autosign_mode    = '0664'
  $autosign_content = undef
  $autosign_source  = undef

  $puppet_cmd = "${bindir}/puppet"

  $manage_packages = true

  if $::osfamily == 'Windows' {
    $dir_owner = undef
    $dir_group = undef
  } elsif $aio_package or $::osfamily == 'Suse' {
    $dir_owner = 'root'
    $dir_group = $root_group
  } else {
    $dir_owner = $user
    $dir_group = $group
  }

  $package_provider = $::osfamily ? {
    'windows' => 'chocolatey',
    default   => undef,
  }

  $package_source = undef

  # Need your own config templates? Specify here:
  $main_template   = 'puppet/puppet.conf.erb'
  $agent_template  = 'puppet/agent/puppet.conf.erb'
  $auth_template   = 'puppet/auth.conf.erb'

  # Allow any to the CRL. Needed in case of puppet CA proxy
  $allow_any_crl_auth = false

  # Authenticated nodes to allow
  $auth_allowed = ['$1']

  # Will this host be a puppet agent ?
  $agent                      = true
  $remove_lock                = true
  $client_certname            = $::clientcert

  # Custom puppetmaster
  # needed due to a PUP-4072
  # more information in https://github.com/theforeman/puppet-foreman/commit/5fe3239da0c6fbac76172f61042a69ab3a7eb4e6
  if defined('$::puppetmaster') {
    $puppetmaster             = $::puppetmaster
  } else {
    $puppetmaster             = undef
  }

  # Hashes containing additional settings
  $additional_settings        = {}
  $agent_additional_settings  = {}
  $server_additional_settings = {}

  # Will this host be a puppetmaster?
  $server                     = false
  $server_ca                  = true
  $server_ca_crl_sync         = false
  $server_reports             = 'foreman'
  $server_passenger           = true
  $server_service_fallback    = true
  $server_passenger_min_instances = abs($::processorcount)
  $server_passenger_pre_start = true
  $server_passenger_ruby      = undef
  $server_httpd_service       = 'httpd'
  $server_external_nodes      = "${dir}/node.rb"
  $server_enc_api             = 'v2'
  $server_report_api          = 'v2'
  $server_request_timeout     = 60
  $server_ca_proxy            = undef
  $server_certname            = $::clientcert
  $server_strict_variables    = false
  $server_rack_arguments      = []
  $server_http                = false
  $server_http_port           = 8139
  $server_http_allow          = []

  # use puppetserver (JVM) or puppet master (Ruby)?
  $server_implementation = $aio_package ? {
    true    => 'puppetserver',
    default => 'master',
  }

  # Need a new master template for the server?
  $server_template      = 'puppet/server/puppet.conf.erb'
  # Template for server settings in [main]
  $server_main_template = 'puppet/server/puppet.conf.main.erb'

  # The script that is run to determine the reported manifest version. Undef
  # means we determine it in server.pp
  $server_config_version       = undef

  # Set 'false' for static environments, or 'true' for git-based workflow
  $server_git_repo             = false
  # Git branch to puppet env mapping for the post receive hook
  $server_git_branch_map       = {}

  # Static environments config, ignore if the git_repo or dynamic_environments is 'true'
  # What environments do we have
  $server_environments         = ['development', 'production']
  # Dynamic environments config (deprecated when directory_environments is true)
  $server_dynamic_environments = false
  # Directory environments config
  $server_directory_environments = true
  # Owner of the environments dir: for cases external service needs write
  # access to manage it.
  $server_environments_owner   = $user
  $server_environments_group   = $root_group
  $server_environments_mode    = '0755'
  # Where we store our puppet environments
  $server_envs_dir             = "${codedir}/environments"
  $server_envs_target          = undef
  # Modules in this directory would be shared across all environments
  $server_common_modules_path  = ["${server_envs_dir}/common", "${codedir}/modules", "${sharedir}/modules"]

  # Dynamic environments config, ignore if the git_repo is 'false'
  # Path to the repository
  $server_git_repo_path       = "${vardir}/puppet.git"
  # mode of the repository
  $server_git_repo_mode       = '0755'
  # user of the repository
  $server_git_repo_user       = $user
  # group of the repository
  $server_git_repo_group      = $user
  # Override these if you need your own hooks
  $server_post_hook_content   = 'puppet/server/post-receive.erb'
  $server_post_hook_name      = 'post-receive'

  # PuppetDB config
  $server_puppetdb_host = undef
  $server_puppetdb_port = 8081
  $server_puppetdb_swf  = false

  # Do you use storeconfigs? (note: not required)
  # - undef if you don't
  # - active_record for 2.X style db
  # - puppetdb for puppetdb
  $server_storeconfigs_backend = undef

  # Passenger config
  $server_app_root = "${dir}/rack"
  $server_ssl_dir  = $ssldir

  $server_package     = undef
  $server_version     = undef

  if $aio_package {
    $client_package = ['puppet-agent']
  } elsif ($::osfamily == 'Debian') {
    $client_package = $deb_naio_package ? {
      true    => ['puppet'],
      default => ['puppet-common', 'puppet']
    }
  } elsif ($::osfamily =~ /(FreeBSD|DragonFly)/) {
    if (versioncmp($::puppetversion, '5.0') > 0) {
      $client_package = ['puppet5']
    } elsif (versioncmp($::puppetversion, '4.0') > 0) {
      $client_package = ['puppet4']
    } else {
      $client_package = ['puppet38']
    }
  } else {
    $client_package = ['puppet']
  }

  $puppetrun_cmd = "${puppet_cmd} kick"
  $puppetca_cmd  = "${puppet_cmd} cert"

  # Puppet service name
  $service_name = 'puppet'

  # Puppet onedshot systemd service and timer name
  $systemd_unit_name = 'puppet-run'
  # Mechanisms to manage and reload/restart the agent
  # If supported on the OS, reloading is prefered since it does not kill a currently active puppet run
  case $::osfamily {
    'Debian' : {
      $agent_restart_command = "/usr/sbin/service ${service_name} reload"
      if  ($::operatingsystem == 'Debian') and (versioncmp($::operatingsystemrelease, '8.0') >= 0) or
          ($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemrelease, '15.04') >= 0)
      {
        $unavailable_runmodes = []
      } else {
        $unavailable_runmodes = ['systemd.timer']
      }
    }
    'Redhat' : {
      # PSBM is a CentOS 6 based distribution
      # it reports its $osreleasemajor as 2, not 6.
      # thats why we're matching for '2' in both parts
      $osreleasemajor = regsubst($::operatingsystemrelease, '^(\d+)\..*$', '\1') # workaround for the possibly missing operatingsystemmajrelease
      $agent_restart_command = $osreleasemajor ? {
        /^(2|5|6)$/ => "/sbin/service ${service_name} reload",
        '7'       => "/usr/bin/systemctl reload-or-restart ${service_name}",
        default   => undef,
      }
      $unavailable_runmodes = $osreleasemajor ? {
        /^(2|5|6)$/ => ['systemd.timer'],
        default   => [],
      }
    }
    'Windows': {
      $agent_restart_command = undef
      $unavailable_runmodes = ['cron', 'systemd.timer']
    }
    'Archlinux': {
      $agent_restart_command = "/usr/bin/systemctl reload-or-restart ${service_name}"
      $unavailable_runmodes = ['cron']
    }
    default  : {
      $agent_restart_command = undef
      $unavailable_runmodes = ['systemd.timer']
    }
  }

  # Foreman parameters
  $lower_fqdn              = downcase($::fqdn)
  $server_foreman          = true
  $server_foreman_facts    = true
  $server_puppet_basedir   = $aio_package ? {
    true  => '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet',
    false => undef,
  }
  $server_foreman_url      = "https://${lower_fqdn}"
  $server_foreman_ssl_ca   = undef
  $server_foreman_ssl_cert = undef
  $server_foreman_ssl_key  = undef

  # Which Parser do we want to use? https://docs.puppetlabs.com/references/latest/configuration.html#parser
  $server_parser = 'current'

  # Timeout for cached environments, changed in puppet 3.7.x
  $server_environment_timeout = undef

  # puppet server configuration file
  $server_jvm_config = $::osfamily ? {
    'RedHat' => '/etc/sysconfig/puppetserver',
    'Debian' => '/etc/default/puppetserver',
    default  => '/etc/default/puppetserver',
  }

  $server_jvm_java_bin      = '/usr/bin/java'

  if versioncmp($::puppetversion, '5.0.0') < 0 {
    $server_jvm_extra_args = '-XX:MaxPermSize=256m'
  } else {
    $server_jvm_extra_args = '-Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger'
  }

  $server_jvm_cli_args = undef

  # This is some very trivial "tuning". See the puppet reference:
  # https://docs.puppet.com/puppetserver/latest/tuning_guide.html
  if ($::memorysize_mb =~ String) {
    $mem_in_mb = scanf($::memorysize_mb, '%i')[0]
  } else {
    $mem_in_mb = 0 + $::memorysize_mb
  }
  if $mem_in_mb >= 2048 {
    $server_jvm_min_heap_size = '2G'
    $server_jvm_max_heap_size = '2G'
    $server_max_active_instances = abs($::processorcount)
  } elsif $mem_in_mb >= 1024 {
    $server_max_active_instances = 1
    $server_jvm_min_heap_size = '1G'
    $server_jvm_max_heap_size = '1G'
  } else {
    # VMs with 1GB RAM and a crash kernel enabled usually have an effective 992MB RAM
    $server_max_active_instances = 1
    $server_jvm_min_heap_size = '768m'
    $server_jvm_max_heap_size = '768m'
  }

  $server_ssl_dir_manage                  = true
  $server_ssl_key_manage                  = true
  $server_default_manifest                = false
  $server_default_manifest_path           = '/etc/puppet/manifests/default_manifest.pp'
  $server_default_manifest_content        = '' # lint:ignore:empty_string_assignment
  $server_max_requests_per_instance       = 0
  $server_idle_timeout                    = 1200000
  $server_web_idle_timeout                = 30000
  $server_connect_timeout                 = 120000
  $server_ca_auth_required                = true
  $server_admin_api_whitelist             = [ 'localhost', $lower_fqdn ]
  $server_ca_client_whitelist             = [ 'localhost', $lower_fqdn ]
  $server_cipher_suites                   = [ 'TLS_RSA_WITH_AES_256_CBC_SHA256', 'TLS_RSA_WITH_AES_256_CBC_SHA', 'TLS_RSA_WITH_AES_128_CBC_SHA256', 'TLS_RSA_WITH_AES_128_CBC_SHA' ]
  $server_ssl_protocols                   = [ 'TLSv1.2' ]
  $server_ssl_chain_filepath              = "${server_ssl_dir}/ca/ca_crt.pem"
  $server_check_for_updates               = true
  $server_environment_class_cache_enabled = false
  $server_allow_header_cert_info          = false

  # Puppetserver >= 2.2 Which auth.conf shall we use?
  $server_use_legacy_auth_conf      = false

  # For Puppetserver, certain configuration parameters are version specific. We assume a particular version here.
  if versioncmp($::puppetversion, '5.0.0') < 0 {
    $server_puppetserver_version = '2.7.0'
  } else {
    $server_puppetserver_version = '5.0.0'
  }

  # For Puppetserver 5, use JRuby 9k?
  $server_puppetserver_jruby9k      = false

  # this switch also controls Ruby profiling, by default disabled for Puppetserver 2.x, enabled for 5.x
  $server_puppetserver_metrics = versioncmp($::puppetversion, '5.0.0') >= 0

  # For Puppetserver 5, should the /puppet/experimental route be enabled?
  $server_puppetserver_experimental = true

  # Normally agents can only fetch their own catalogs.  If you want some nodes to be able to fetch *any* catalog, add them here.
  $server_puppetserver_trusted_agents = []
}
