# Default parameters
class puppet::params {

  # Basic config
  $version             = 'present'
  $user                = 'puppet'
  $group               = 'puppet'
  $port                = 8140
  $listen              = false
  $listen_to           = []
  $pluginsync          = true
  $splay               = false
  $splaylimit          = '1800'
  $autosign            = '$confdir/autosign.conf { mode = 664 }'
  $runinterval         = '1800'
  $runmode             = 'service'
  $cron_cmd            = undef
  $agent_noop          = false
  $show_diff           = false
  $module_repository   = undef
  if versioncmp($::puppetversion, '4.0') < 0 {
    $configtimeout     = 120
  } else {
    $configtimeout     = undef
  }
  $usecacheonfailure   = true
  $ca_server           = undef
  $ca_port             = undef
  $prerun_command      = undef
  $postrun_command     = undef
  $dns_alt_names       = []
  $use_srv_records     = false
  $srv_domain          = $::domain
  # lint:ignore:puppet_url_without_modules
  $pluginsource        = 'puppet:///plugins'
  $pluginfactsource    = 'puppet:///pluginfacts'
  # lint:endignore
  $classfile           = '$statedir/classes.txt'
  $hiera_config        = '$confdir/hiera.yaml'
  $syslogfacility      = undef
  $environment         = $::environment
  if versioncmp($::puppetversion, '4.0') < 0 {
    $aio_package = false
  } elsif $::osfamily == 'Windows' or $::rubysitedir =~ /\/opt\/puppetlabs\/puppet/ {
    $aio_package = true
  } else {
    $aio_package = false
  }

  case $::osfamily {
    'Windows' : {
      # Windows prefixes normal paths with the Data Directory's path and leaves 'puppet' off the end
      $dir_prefix = 'C:/ProgramData/PuppetLabs/puppet'

      $dir        = "${dir_prefix}/etc"
      $codedir    = "${dir_prefix}/etc"
      $logdir     = "${dir_prefix}/var/log"
      $rundir     = "${dir_prefix}/var/run"
      $ssldir     = "${dir_prefix}/etc/ssl"
      $vardir     = "${dir_prefix}/var"
      $sharedir   = "${dir_prefix}/share"
      $root_group = undef
    }

    /^(FreeBSD|DragonFly)$/ : {
      $dir        = '/usr/local/etc/puppet'
      $codedir    = '/usr/local/etc/puppet'
      $logdir     = '/var/log/puppet'
      $rundir     = '/var/run/puppet'
      $ssldir     = '/var/puppet/ssl'
      $vardir     = '/var/puppet'
      $sharedir   = '/usr/local/share/puppet'
      $root_group = undef
    }

    default : {
      if $aio_package {
        $dir      = '/etc/puppetlabs/puppet'
        $codedir  = '/etc/puppetlabs/code'
        $logdir   = '/var/log/puppetlabs/puppet'
        $rundir   = '/var/run/puppetlabs'
        $ssldir   = '/etc/puppetlabs/puppet/ssl'
        $vardir   = '/opt/puppetlabs/puppet/cache'
        $sharedir = '/opt/puppetlabs/puppet'
      } else {
        $dir        = '/etc/puppet'
        $codedir    = '/etc/puppet'
        $logdir     = '/var/log/puppet'
        $rundir     = '/var/run/puppet'
        $ssldir     = '/var/lib/puppet/ssl'
        $vardir     = '/var/lib/puppet'
        $sharedir   = '/usr/share/puppet'
      }
      $root_group = undef
    }
  }

  $manage_packages = true

  if $aio_package and $::osfamily != 'Windows' {
    $dir_owner = 'root'
    $dir_group = $root_group
  } elsif $::osfamily == 'Windows' {
    $dir_owner = undef
    $dir_group = undef
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
  $nsauth_template = 'puppet/namespaceauth.conf.erb'

  # Allow any to the CRL. Needed in case of puppet CA proxy
  $allow_any_crl_auth = false

  # Authenticated nodes to allow
  $auth_allowed = ['$1']

  # Will this host be a puppet agent ?
  $agent                     = true
  $remove_lock               = true

  # Custom puppetmaster
  if defined('$trusted') and $::trusted['authenticated'] == 'local' {
    $puppetmaster            = undef
  } else {
    $puppetmaster            = $::puppetmaster
  }

  # Hashes containing additional settings
  $additional_settings   =      {}
  $agent_additional_settings  = {}
  $server_additional_settings = {}

  # Will this host be a puppetmaster?
  $server                     = false
  $server_ca                  = true
  $server_reports             = 'foreman'
  $server_implementation      = 'master'
  $server_passenger           = true
  $server_service_fallback    = true
  $server_passenger_max_pool  = 12
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

  # Need a new master template for the server?
  $server_template = 'puppet/server/puppet.conf.erb'

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
  $server_directory_environments = versioncmp($::puppetversion, '3.6.0') >= 0
  # Owner of the environments dir: for cases external service needs write
  # access to manage it.
  $server_environments_owner   = $user
  $server_environments_group   = $root_group
  $server_environments_mode    = '0755'
  # Where we store our puppet environments
  $server_envs_dir             = "${codedir}/environments"
  # Where remains our manifests dir
  $server_manifest_path        = "${codedir}/manifests"
  # Modules in this directory would be shared across all environments
  $server_common_modules_path  = ["${server_envs_dir}/common", "${codedir}/modules", "${sharedir}/modules"]

  # Dynamic environments config, ignore if the git_repo is 'false'
  # Path to the repository
  $server_git_repo_path       = "${vardir}/puppet.git"
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
  $client_package     = $aio_package ? {
    true       => ['puppet-agent'],
    default    => $::osfamily ? {
      'Debian' => ['puppet-common','puppet'],
      default  => ['puppet'],
    },
  }

  # Only use 'puppet cert' on versions where puppetca no longer exists
  if versioncmp($::puppetversion, '3.0') < 0 {
    $puppetca_path = '/usr/sbin'
    $puppetca_bin  = 'puppetca'
    $puppetrun_cmd = '/usr/sbin/puppetrun'
  } elsif $aio_package {
    $puppetca_path = '/opt/puppetlabs/bin'
    $puppetca_bin = 'puppet cert'
    $puppetrun_cmd = '/opt/puppetlabs/bin/puppet kick'
  } else {
    $puppetca_path = $::osfamily ? {
      /^(FreeBSD|DragonFly)$/ => '/usr/local/bin',
      default                 => '/usr/bin'
    }
    $puppetca_bin = 'puppet cert'
    $puppetrun_cmd = $::osfamily ? {
      /^(FreeBSD|DragonFly)$/ => '/usr/local/bin/puppet kick',
      default                 => '/usr/bin/puppet kick'
    }
  }

  $puppetca_cmd = "${puppetca_path}/${puppetca_bin}"

  # Puppet service name
  $service_name = 'puppet'
  # Command to reload/restart the agent
  # If supported on the OS, reloading is prefered since it does not kill a currently active puppet run
  case $::osfamily {
    'Debian' : {
      $agent_restart_command = "/usr/sbin/service ${service_name} reload"
    }
    'Redhat' : {
      $osreleasemajor = regsubst($::operatingsystemrelease, '^(\d+)\..*$', '\1') # workaround for the possibly missing operatingsystemmajrelease
      $agent_restart_command = $osreleasemajor ? {
        '6'     => "/sbin/service ${service_name} reload",
        '7'     => "/usr/bin/systemctl reload-or-restart ${service_name}",
        default => undef,
      }
    }
    default  : {
      $agent_restart_command = undef
    }
  }

  # Foreman parameters
  $server_foreman          = true
  $server_facts            = true
  $server_puppet_basedir   = undef
  $server_foreman_url      = "https://${::fqdn}"
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

  $server_jvm_java_bin = '/usr/bin/java'
  $server_jvm_min_heap_size = '2G'
  $server_jvm_max_heap_size = '2G'
  $server_jvm_extra_args = '' # lint:ignore:empty_string_assignment

}
