class puppet::server (
  $user                = $puppet::params::user,
  $dir                 = $puppet::params::dir,
  $ca                  = $puppet::params::ca,
  $passenger           = $puppet::params::passenger,
  $port                = $puppet::params::port,
  $environments        = $puppet::params::environments,
  $modules_path        = $puppet::params::modules_path,
  $common_modules_path = $puppet::params::common_modules_path,
  $git_repo            = $puppet::params::git_repo,
  $git_repo_path       = $puppet::params::git_repo_path,
  $envs_dir            = $puppet::params::envs_dir,
  $app_root            = $puppet::params::app_root,
  $ssl_dir             = $puppet::params::ssl_dir,
  $master_package      = $puppet::params::master_package,
  $post_hook_content   = $puppet::params::post_hook_content,
  $post_hook_name      = $puppet::params::post_hook_name,
  $agent_template      = $puppet::params::agent_template,
  $master_template     = $puppet::params::master_template
) inherits puppet::params {
  class { 'puppet::server::install': }~>
  class { 'puppet::server::config': }
}
