class puppet::params {

  include foreman::params
  $user                = 'puppet'
  $dir                 = '/etc/puppet'
  $ca                  = true
  $passenger           = true

  # use static environments or ignore the following line and enable git dynamic environments
  $environments        = ['development', 'production']
  # where we store our puppet modules
  $modules_path        = "${dir}/modules"
  # modules in this directory would be shared across all environments
  $common_modules_path = "${modules_path}/common"

  $git_repo            = false
  $git_repo_path       = '/var/lib/puppet/puppet.git'
  $envs_dir            = "${dir}/environments"

  $apache_conf_dir     = $foreman::params::apache_conf_dir
  $app_root            = "${dir}/rack"
  $ssl_dir             = '/var/lib/puppet/ssl'

  $master_package      = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => ['puppetmaster'],
    default           => ['puppet-server'],
  }

  $cron_range          = 60 # the maximum value for our cron
  $cron_interval       = 2  # the amount of values within the $cron_range
}
