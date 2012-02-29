class puppet::params {

  include foreman::params
  $user                = 'puppet'
  $dir                 = '/etc/puppet'
  $envs_dir            = "${dir}/environments"
  $ca                  = true
  $passenger           = true
  $git_repo            = true
  $apache_conf_dir     = $foreman::params::apache_conf_dir
  $app_root            = "${dir}/rack"
  $ssl_dir             = '/var/lib/puppet/ssl'
  $master_package      = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => ['puppetmaster'],
    default           => ['puppet-server'],
  }

}
