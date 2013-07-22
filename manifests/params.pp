# Default parameters
class puppet::params {

  # Basic config
  $version             = 'present'
  $user                = 'puppet'
  $group               = 'puppet'
  $dir                 = '/etc/puppet'
  $vardir              = '/var/lib/puppet'
  $ca                  = true
  $ca_server           = false
  $passenger           = true
  $service_fallback    = true
  $passenger_max_pool  = 12
  $httpd_service       = 'httpd'
  $port                = 8140
  $listen              = false
  $pluginsync          = true
  $splay               = false
  $runinterval         = '1800'
  $runmode             = 'service'
  $agent_noop          = false
  $external_nodes      = '/etc/puppet/node.rb'
  $reports             = 'foreman'


  # Need your own config templates? Specify here:
  $agent_template  = 'puppet/puppet.conf.erb'
  $master_template = 'puppet/server/puppet.conf.erb'
  $auth_template   = 'puppet/auth.conf.erb'
  $nsauth_template = 'puppet/namespaceauth.conf.erb'

  # Set 'false' for staic environments, or 'true' for git-based workflow
  $git_repo            = false

  # The script that is run to determine the reported manifest version. Undef
  # means we determine it in server.pp
  $config_version      = undef

  # Static environments config, ignore if the git_repo is 'true'
  # What environments do we have
  $environments        = ['development', 'production']
  # Where we store our puppet environments
  $envs_dir            = "${dir}/environments"
  # Where remains our manifests dir
  $manifest_path       = "${dir}/manifests"
  # Modules in this directory would be shared across all environments
  $common_modules_path = ["${envs_dir}/common", '/usr/share/puppet/modules']

  # Dynamic environments config, ignore if the git_repo is 'false'
  # Path to the repository
  $git_repo_path       = "${vardir}/puppet.git"
  # Override these if you need your own hooks
  $post_hook_content   = 'puppet/server/post-receive.erb'
  $post_hook_name      = 'post-receive'

  # Do you use storeconfigs? (note: not required)
  # - false if you don't
  # - active_record for 2.X style db
  # - puppetdb for puppetdb
  $storeconfigs_backend = false

  # Passenger config
  $app_root            = "${dir}/rack"
  $ssl_dir             = "${vardir}/ssl"

  $master_package     =  $::operatingsystem ? {
    /(Debian|Ubuntu)/ => ['puppetmaster-common','puppetmaster'],
    default           => ['puppet-server'],
  }
  $client_package     = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => ['puppet-common','puppet'],
    default           => ['puppet'],
  }

  # This only applies to puppet::cron
  $cron_range          = 60 # the maximum value for our cron
  $cron_interval       = 2  # the amount of values within the $cron_range

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
}
