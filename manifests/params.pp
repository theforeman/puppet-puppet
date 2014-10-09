# Default parameters
class puppet::params {

  include foreman::params

  # Basic config
  $version             = 'present'
  $user                = 'puppet'
  $group               = 'puppet'
  $dir                 = '/etc/puppet'
  $port                = 8140
  $listen              = false
  $pluginsync          = true
  $splay               = false
  $splaylimit          = '1800'
  $runinterval         = '1800'
  $runmode             = 'service'
  $cron_cmd            = undef
  $agent_noop          = false
  $show_diff           = false
  $configtimeout       = 120
  $usecacheonfailure   = true
  $ca_server           = ''
  $dns_alt_names       = []
  $use_srv_records     = false
  $srv_domain          = $::domain
  # lint:ignore:puppet_url_without_modules
  $pluginsource        = 'puppet:///plugins'
  # lint:endignore
  $classfile           = '$vardir/classes.txt'
  $hiera_config        = '$confdir/hiera.yaml'
  $syslogfacility      = undef

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

  # Custom puppetmaster
  $puppetmaster              = $::puppetmaster

  # Will this host be a puppetmaster?
  $server                    = false
  $server_vardir             = '/var/lib/puppet'
  $server_ca                 = true
  $server_reports            = 'foreman'
  $server_implementation     = 'master'
  $server_passenger          = true
  $server_service_fallback   = true
  $server_passenger_max_pool = 12
  $server_httpd_service      = 'httpd'
  $server_external_nodes     = '/etc/puppet/node.rb'
  $server_enc_api            = 'v2'
  $server_report_api         = 'v2'
  $server_ca_proxy           = ''
  $server_certname           = $::clientcert
  $server_strict_variables   = false

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
  $server_environments_group   = 'root'
  $server_environments_mode    = '0755'
  # Where we store our puppet environments
  $server_envs_dir             = "${dir}/environments"
  # Where remains our manifests dir
  $server_manifest_path        = "${dir}/manifests"
  # Modules in this directory would be shared across all environments
  $server_common_modules_path  = ["${server_envs_dir}/common", "${dir}/modules", '/usr/share/puppet/modules']

  # Dynamic environments config, ignore if the git_repo is 'false'
  # Path to the repository
  $server_git_repo_path       = "${server_vardir}/puppet.git"
  # Override these if you need your own hooks
  $server_post_hook_content   = 'puppet/server/post-receive.erb'
  $server_post_hook_name      = 'post-receive'

  # Do you use storeconfigs? (note: not required)
  # - undef if you don't
  # - active_record for 2.X style db
  # - puppetdb for puppetdb
  $server_storeconfigs_backend = undef

  # Passenger config
  $server_app_root = "${dir}/rack"
  $server_ssl_dir  = "${server_vardir}/ssl"

  $server_package     = undef
  $client_package     = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => ['puppet-common','puppet'],
    default           => ['puppet'],
  }

  # Only use 'puppet cert' on versions where puppetca no longer exists
  if versioncmp($::puppetversion, '3.0') < 0 {
    $puppetca_path = '/usr/sbin'
    $puppetca_bin  = 'puppetca'
    $puppetrun_cmd = '/usr/sbin/puppetrun'
  } else {
    $puppetca_path = '/usr/bin'
    $puppetca_bin = 'puppet cert'
    $puppetrun_cmd = '/usr/bin/puppet kick'
  }

  $puppetca_cmd = "${puppetca_path}/${puppetca_bin}"

  # Puppet service name
  $service_name = 'puppet'
}
