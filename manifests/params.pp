class puppet::params {

  include foreman::params

  # Basic config
  $version             = 'present'
  $user                = 'puppet'
  $dir                 = '/etc/puppet'
  $ca                  = true
  $passenger           = true
  $port                = 8140
  $listen              = false

  # Need your own config templates? Specify here:
  $agent_template  = 'puppet/puppet.conf.erb'
  $master_template = 'puppet/server/puppet.conf.erb'
  $auth_template   = 'puppet/auth.conf.erb'
  $nsauth_template = 'puppet/namespaceauth.conf.erb'

  # Set 'false' for staic environments, or 'true' for git-based workflow
  $git_repo            = false

  # Static environments config, ignore if the git_repo is 'true'
  # What environments do we have
  $environments        = ['development', 'production']
  # Where we store our puppet modules
  $modules_path        = "${dir}/modules"
  # Where remains our manifests dir
  $manifest_path       = "${dir}/manifests"
  # Modules in this directory would be shared across all environments
  $common_modules_path = "${modules_path}/common"

  # Dynamic environments config, ignore if the git_repo is 'false'
  # Path to the repository
  $git_repo_path       = '/var/lib/puppet/puppet.git'
  # Where to checkout the branches
  $envs_dir            = "${dir}/environments"
  # Override these if you need your own hooks
  $post_hook_content   = 'puppet/server/post-receive.erb'
  $post_hook_name      = 'post-receive'

  # Passenger config
  $app_root            = "${dir}/rack"
  $ssl_dir             = '/var/lib/puppet/ssl'

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
  if versioncmp($puppetversion, '3.0') < 0 {
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
