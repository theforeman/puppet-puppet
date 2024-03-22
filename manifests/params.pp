# Default parameters
# @api private
class puppet::params {
  # Basic config
  $version             = 'present'
  $manage_user         = true
  $user                = 'puppet'
  $group               = 'puppet'
  $ip                  = '0.0.0.0'
  $agent_server_port   = 8140
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
  $localconfig         = '$vardir/localconfig'
  $usecacheonfailure   = true
  $ca_server           = undef
  $ca_port             = undef
  $ca_crl_filepath     = undef
  $certificate_revocation = undef
  $server_crl_enable   = undef
  $prerun_command      = undef
  $postrun_command     = undef
  $server_compile_mode = undef
  $dns_alt_names       = []
  $use_srv_records     = false
  $agent_default_schedules = false

  $srv_domain = fact('networking.domain')

  # lint:ignore:puppet_url_without_modules
  $pluginsource        = 'puppet:///plugins'
  $pluginfactsource    = 'puppet:///pluginfacts'
  # lint:endignore
  $classfile           = '$statedir/classes.txt'
  $syslogfacility      = undef
  $environment         = $server_facts['environment']

  # aio_agent_version is a core fact that's empty on non-AIO
  $aio_package      = fact('aio_agent_version') =~ String[1]

  $systemd_randomizeddelaysec = 0

  case $facts['os']['family'] {
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
      $puppetconf_mode            = '0674'
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
      if fact('ruby') {
        $ruby_gem_dir               = regsubst($facts['ruby']['version'], '^(\d+\.\d+).*$', '/usr/local/lib/ruby/gems/\1/gems')
        $server_ruby_load_paths     = [$facts['ruby']['sitedir'], "${ruby_gem_dir}/facter-${facts['facterversion']}/lib"]
      } else {
        # On FreeBSD 11 the ruby fact doesn't resolve - at least in facterdb
        # lint:ignore:legacy_facts
        $ruby_gem_dir               = regsubst($facts['rubyversion'], '^(\d+\.\d+).*$', '/usr/local/lib/ruby/gems/\1/gems')
        $server_ruby_load_paths     = [$facts['rubysitedir'], "${ruby_gem_dir}/facter-${facts['facterversion']}/lib"]
        # lint:endignore
      }
      $server_jruby_gem_home      = '/var/puppet/server/data/puppetserver/jruby-gems'
      $puppetconf_mode            = '0644'
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
      $puppetconf_mode            = '0644'
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
        $codedir                    =  $facts['os']['family'] ? {
          'Debian' => '/etc/puppet/code',
          default  => '/etc/puppet',
        }
        $logdir                     = '/var/log/puppet'
        $rundir                     = '/var/run/puppet'
        $ssldir                     = '/var/lib/puppet/ssl'
        $vardir                     = '/var/lib/puppet'
        $sharedir                   = '/usr/share/puppet'
        $bindir                     = '/usr/bin'
        if $facts['os']['family'] == 'Debian' {
          $server_puppetserver_dir    = '/etc/puppet/puppetserver'
          $server_puppetserver_vardir = '/var/lib/puppetserver'
          $server_puppetserver_rundir = '/run/puppetserver'
          $server_puppetserver_logdir = '/var/log/puppetserver'
          $server_ruby_load_paths     = ['/usr/lib/puppetserver/ruby/vendor_ruby']
          $server_jruby_gem_home      = '/var/lib/puppetserver/jruby-gems'
        } else {
          $server_puppetserver_dir    = '/etc/puppetserver'
          $server_puppetserver_vardir = $vardir
          $server_puppetserver_rundir = undef
          $server_puppetserver_logdir = undef
          $server_ruby_load_paths     = []
          $server_jruby_gem_home      = '/var/lib/puppet/jruby-gems'
        }
      }
      $root_group = undef
      $puppetconf_mode = '0644'
    }
  }

  $http_connect_timeout = undef
  $http_read_timeout = undef

  $autosign         = "${dir}/autosign.conf"
  $autosign_entries = []
  $autosign_mode    = '0664'
  $autosign_content = undef
  $autosign_source  = undef

  $puppet_cmd = "${bindir}/puppet"
  $puppetserver_cmd = "${bindir}/puppetserver"

  $manage_packages = true

  if $facts['os']['family'] == 'Windows' {
    $dir_owner = undef
    $dir_group = undef
  } else {
    $dir_owner = 'root'
    $dir_group = $root_group
  }

  $package_provider = $facts['os']['family'] ? {
    'windows' => 'chocolatey',
    default   => undef,
  }

  $package_source = undef
  $package_install_options = undef

  # Allow any to the CRL. Needed in case of puppet CA proxy
  $allow_any_crl_auth = false

  # Authenticated nodes to allow
  $auth_allowed = ['$1']

  # Will this host be a puppet agent ?
  $agent                      = true
  $client_certname            = $trusted['certname']

  # Set by the Foreman ENC
  $agent_server_hostname = getvar('puppetmaster')

  # Hashes containing additional settings
  $additional_settings        = {}
  $agent_additional_settings  = {}
  $server_additional_settings = {}

  # Will this host be a puppetserver?
  $server                          = false
  $server_ca                       = true
  $server_ca_crl_sync              = false
  $server_reports                  = 'foreman'
  $server_external_nodes           = "${dir}/node.rb"
  $server_trusted_external_command = undef
  $server_request_timeout          = 60
  $server_certname                 = $trusted['certname']
  $server_strict_variables         = false
  $server_http                     = false
  $server_http_port                = 8139

  # Need a new server template for the server?
  $server_template      = 'puppet/server/puppet.conf.erb'
  # Template for server settings in [main]
  $server_main_template = 'puppet/server/puppet.conf.main.erb'

  # Set 'false' for static environments, or 'true' for git-based workflow
  $server_git_repo             = false
  # Git branch to puppet env mapping for the post receive hook
  $server_git_branch_map       = {}

  # Owner of the environments dir: for cases external service needs write
  # access to manage it.
  $server_environments_owner   = $user
  $server_environments_group   = $root_group
  $server_environments_mode    = '0755'
  $server_environments_recurse = false
  # Where we store our puppet environments
  $server_envs_dir             = ["${codedir}/environments"]
  $server_envs_target          = undef
  # Modules in this directory would be shared across all environments
  $server_common_modules_path  = unique(["${server_envs_dir[0]}/common", "${codedir}/modules", "${sharedir}/modules", '/usr/share/puppet/modules'])

  # Dynamic environments config, ignore if the git_repo is 'false'
  # Path to the repository on disk
  $server_git_repo_path       = "${vardir}/puppet.git"
  # Umask for vcsrepo operations
  $server_git_repo_umask      = '0022'
  # mode of the repository hooks
  $server_git_repo_hook_mode  = '0755'
  # user of the repository
  $server_git_repo_user       = $user
  # group of the repository
  $server_git_repo_group      = $user
  # Override these if you need your own hooks
  $server_post_hook_content   = 'puppet/server/post-receive.erb'
  $server_post_hook_name      = 'post-receive'
  $server_custom_trusted_oid_mapping = undef

  $server_storeconfigs = false

  $puppet_major = regsubst($facts['puppetversion'], '^(\d+)\..*$', '\1')

  if ($facts['os']['family'] =~ /(FreeBSD|DragonFly)/) {
    $server_package = "puppetserver${puppet_major}"
  } else {
    $server_package = undef
  }

  $server_ssl_dir = $ssldir
  $server_version = undef

  if $aio_package or
  ($facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['major'], '12') >= 0) {
    $client_package = ['puppet-agent']
  } elsif ($facts['os']['family'] =~ /(FreeBSD|DragonFly)/) {
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
  if $facts['service_provider'] == 'systemd' {
    $agent_restart_command = "/bin/systemctl reload-or-restart ${service_name}"
    $unavailable_runmodes = $facts['os']['family'] ? {
      'Archlinux' => ['cron'],
      default     => [],
    }
  } else {
    case $facts['os']['family'] {
      'Debian': {
        $agent_restart_command = "/usr/sbin/service ${service_name} reload"
        $unavailable_runmodes = ['systemd.timer']
      }
      'RedHat': {
        $agent_restart_command = "/sbin/service ${service_name} reload"
        $unavailable_runmodes = ['systemd.timer']
      }
      'Windows': {
        $agent_restart_command = undef
        $unavailable_runmodes = ['cron', 'systemd.timer']
      }
      default  : {
        $agent_restart_command = undef
        $unavailable_runmodes = ['systemd.timer']
      }
    }
  }

  # Foreman parameters
  $lower_fqdn              = downcase($facts['networking']['fqdn'])
  $server_foreman          = true
  $server_foreman_facts    = true
  $server_puppet_basedir   = $aio_package ? {
    true  => '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet',
    false => undef,
  }
  $server_foreman_url      = undef
  $server_foreman_ssl_ca   = undef
  $server_foreman_ssl_cert = undef
  $server_foreman_ssl_key  = undef

  # Which Parser do we want to use? https://docs.puppetlabs.com/references/latest/configuration.html#parser
  $server_parser = 'current'

  # Timeout for cached environments, changed in puppet 3.7.x
  $server_environment_timeout = undef

  # puppet server configuration file
  $server_jvm_config = $facts['os']['family'] ? {
    'RedHat' => '/etc/sysconfig/puppetserver',
    'Debian' => '/etc/default/puppetserver',
    default  => '/etc/default/puppetserver',
  }

  $server_jvm_extra_args = undef
  $server_jvm_cli_args   = undef

  # This is some very trivial "tuning". See the puppet reference:
  # https://docs.puppet.com/puppetserver/latest/tuning_guide.html
  $mem_in_mb = $facts['memory']['system']['total_bytes'] / 1024 / 1024
  if $mem_in_mb >= 3072 {
    $server_jvm_min_heap_size = '2G'
    $server_jvm_max_heap_size = '2G'
    $server_max_active_instances = min(abs($facts['processors']['count']), 4)
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
  $server_multithreaded                   = false
  $server_idle_timeout                    = 1200000
  $server_web_idle_timeout                = 30000
  $server_connect_timeout                 = 120000
  $server_ca_auth_required                = true
  $server_ca_client_self_delete           = false
  $server_admin_api_allowlist             = ['localhost', $lower_fqdn]
  $server_ca_client_allowlist             = ['localhost', $lower_fqdn]
  $server_cipher_suites                   = [
    'TLS_AES_128_GCM_SHA256',
    'TLS_AES_256_GCM_SHA384',
    'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256',
    'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
    'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
    'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
    'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
    'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
  ]
  $server_ssl_protocols                   = ['TLSv1.3', 'TLSv1.2']
  $server_ssl_chain_filepath              = undef
  $server_check_for_updates               = true
  $server_environment_class_cache_enabled = false
  $server_allow_header_cert_info          = false
  $server_ca_allow_sans                   = false
  $server_ca_allow_auth_extensions        = false
  $server_ca_enable_infra_crl             = false
  $server_ca_allow_auto_renewal           = false
  $server_ca_allow_auto_renewal_cert_ttl  = '60d'
  $server_max_open_files                  = undef
  $server_environment_vars                = {}

  $server_puppetserver_version      = undef

  # Puppetserver metrics shipping
  $server_metrics_jmx_enable        = true
  $server_metrics_graphite_enable   = false
  $server_metrics_graphite_host     = '127.0.0.1'
  $server_metrics_graphite_port     = 2003
  $server_metrics_server_id         = $lower_fqdn
  $server_metrics_graphite_interval = 5
  $server_metrics_allowed           = undef

  # Should the /puppet/experimental route be enabled?
  $server_puppetserver_experimental = true

  # For custom auth.conf settings allow passing in a template
  $server_puppetserver_auth_template = undef

  # Normally agents can only fetch their own catalogs.  If you want some nodes to be able to fetch *any* catalog, add them here.
  $server_puppetserver_trusted_agents = []
  $server_puppetserver_trusted_certificate_extensions = []
}
