class puppet::params {

  include foreman::params
  $user                = 'puppet'
  $dir                 = '/etc/puppet'
  $modules_path        = "${dir}/modules"
  $common_modules_path = "${modules_path}/common"
  $environments        = ['development', 'production']
  $ca                  = true
  $passenger           = true
  $apache_conf_dir     = $foreman::params::apache_conf_dir
  $app_root            = "${dir}/rack"
  $ssl_dir             = '/var/lib/puppet/ssl'

}
