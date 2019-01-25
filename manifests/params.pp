# Default parameters
# @api private
class puppet::params {

  # Basic config
  $version             = 'present'
  $manage_user         = true
  $user                = 'puppet'
  $group               = 'puppet'
  $ip                  = '0.0.0.0'
  $port                = 8140
  $listen              = false
  $listen_to           = []
  $pluginsync          = true
  $splay               = false
  $splaylimit          = 1800
  $runinterval         = 1800
  $runmode             = 'service'
  $report              = true

  # Not defined here as the commands depend on module parameter "dir"
  $cron_cmd            = undef
  $systemd_cmd         = undef

  $agent_noop          = false
  $show_diff           = false
  $module_repository   = undef
  $hiera_config        = '$confdir/hiera.yaml'
  $usecacheonfailure   = true
  $ca_server           = undef
  $ca_port             = undef
  $ca_crl_filepath     = undef
  $server_crl_enable   = undef
  $prerun_command      = undef
  $postrun_command     = undef
  $server_compile_mode = undef
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

  $aio_package      = ($::osfamily == 'Windows' or $::rubysitedir =~ /\/opt\/puppetlabs\/puppet/)

  $systemd_randomizeddelaysec = 0

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
        $codedir                    =  $::osfamily ? {
          'Debian' => '/etc/puppet/code',
          default  => '/etc/puppet',
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

  $configtimeout = undef

  $autosign         = "${dir}/autosign.conf"
  $autosign_entries = []
  $autosign_mode    = '0664'
  $autosign_content = undef
  $autosign_source  = undef

  $puppet_cmd = "${bindir}/puppet"
  $puppetserver_cmd = "${bindir}/puppetserver"

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
  $auth_template   = 'puppet/auth.conf.erb'

  # Allow any to the CRL. Needed in case of puppet CA proxy
  $allow_any_crl_auth = false

  # Authenticated nodes to allow
  $auth_allowed = ['$1']

  # Will this host be a puppet agent ?
  $agent                      = true
  $remove_lock                = true
  $client_certname            = $::clientcert

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
  $server_external_nodes      = "${dir}/node.rb"
  $server_enc_api             = 'v2'
  $server_report_api          = 'v2'
  $server_request_timeout     = 60
  $server_certname            = $::clientcert
  $server_strict_variables    = false
  $server_http                = false
  $server_http_port           = 8139

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

  # Owner of the environments dir: for cases external service needs write
  # access to manage it.
  $server_environments_owner   = $user
  $server_environments_group   = $root_group
  $server_environments_mode    = '0755'
  # Where we store our puppet environments
  $server_envs_dir             = "${codedir}/environments"
  $server_envs_target          = undef
  # Modules in this directory would be shared across all environments
  $server_common_modules_path  = unique(["${server_envs_dir}/common", "${codedir}/modules", "${sharedir}/modules", '/usr/share/puppet/modules'])

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
  $server_custom_trusted_oid_mapping = undef

  # PuppetDB config
  $server_puppetdb_host = undef
  $server_puppetdb_port = 8081
  $server_puppetdb_swf  = false

  # Do you use storeconfigs? (note: not required)
  # - undef if you don't
  # - active_record for 2.X style db
  # - puppetdb for puppetdb
  $server_storeconfigs_backend = undef

  $puppet_major = regsubst($::puppetversion, '^(\d+)\..*$', '\1')

  if ($::osfamily =~ /(FreeBSD|DragonFly)/ and versioncmp($puppet_major, '5') >= 0) {
    $server_package = "puppetserver${puppet_major}"
  } else {
    $server_package = undef
  }

  $server_ssl_dir = $ssldir
  $server_version = undef

  if $aio_package {
    $client_package = ['puppet-agent']
  } elsif ($::osfamily =~ /(FreeBSD|DragonFly)/) {
    $client_package = ["puppet${puppet_major}"]
  } else {
    $client_package = ['puppet']
  }

  # Puppet service name
  $service_name = 'puppet'

  # Puppet onedshot systemd service and timer name
  $systemd_unit_name = 'puppet-run'
  # Mechanisms to manage and reload/restart the agent
  # If supported on the OS, reloading is prefered since it does not kill a currently active puppet run
  case $::osfamily {
    'Debian' : {
      $agent_restart_command = "/usr/sbin/service ${service_name} reload"
      if ($::operatingsystem == 'Debian' or $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '15.04') >= 0) {
        $unavailable_runmodes = []
      } else {
        $unavailable_runmodes = ['systemd.timer']
      }
    }
    'Redhat' : {
      # PSBM is a CentOS 6 based distribution
      # it reports its $osreleasemajor as 2, not 6.
      # thats why we're matching for '2' in both parts
      # Amazon Linux is like RHEL6 but reports its osreleasemajor as 2017.
      $osreleasemajor = regsubst($::operatingsystemrelease, '^(\d+)\..*$', '\1') # workaround for the possibly missing operatingsystemmajrelease
      $agent_restart_command = $osreleasemajor ? {
        /^(2|5|6|2017)$/ => "/sbin/service ${service_name} reload",
        '7'       => "/usr/bin/systemctl reload-or-restart ${service_name}",
        default   => undef,
      }
      $unavailable_runmodes = $osreleasemajor ? {
        /^(2|5|6|2017)$/ => ['systemd.timer'],
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

  $server_jvm_java_bin   = '/usr/bin/java'
  $server_jvm_extra_args = undef
  $server_jvm_cli_args   = undef

  # This is some very trivial "tuning". See the puppet reference:
  # https://docs.puppet.com/puppetserver/latest/tuning_guide.html
  if ($::memorysize_mb =~ String) {
    $mem_in_mb = scanf($::memorysize_mb, '%i')[0]
  } else {
    $mem_in_mb = 0 + $::memorysize_mb
  }
  if $mem_in_mb >= 3072 {
    $server_jvm_min_heap_size = '2G'
    $server_jvm_max_heap_size = '2G'
    $server_max_active_instances = min(abs($::processorcount), 4)
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
  $server_max_queued_requests             = 0
  $server_max_retry_delay                 = 1800
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
  $server_ca_allow_sans                   = false
  $server_ca_allow_auth_extensions        = false
  $server_ca_enable_infra_crl             = false
  $server_max_open_files                  = undef

  $server_puppetserver_version      = undef

  # Puppetserver >= 2.2 Which auth.conf shall we use?
  $server_use_legacy_auth_conf      = false

  # For Puppetserver 5, use JRuby 9k?
  $server_puppetserver_jruby9k      = false

  # this switch also controls Ruby profiling, by default disabled for Puppetserver 2.x, enabled for 5.x
  $server_puppetserver_metrics = undef

  # Puppetserver metrics shipping
  $server_metrics_jmx_enable        = true
  $server_metrics_graphite_enable   = false
  $server_metrics_graphite_host     = '127.0.0.1'
  $server_metrics_graphite_port     = 2003
  $server_metrics_server_id         = $lower_fqdn
  $server_metrics_graphite_interval = 5
  $server_metrics_allowed           = undef

  # For Puppetserver 5, should the /puppet/experimental route be enabled?
  $server_puppetserver_experimental = true

  # Normally agents can only fetch their own catalogs.  If you want some nodes to be able to fetch *any* catalog, add them here.
  $server_puppetserver_trusted_agents = []
}
