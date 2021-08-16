# Default parameters
# @api private
class puppet::params {
  $server_user  = 'puppet'
  $server_group = 'puppet'
  $srv_domain   = fact('networking.domain')
  $environment  = $::environment
  # aio_agent_version is a core fact that's empty on non-AIO
  $aio_package = fact('aio_agent_version') =~ String[1]

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

  $autosign         = "${dir}/autosign.conf"

  $puppet_cmd = "${bindir}/puppet"
  $puppetserver_cmd = "${bindir}/puppetserver"

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

  $client_certname            = $::clientcert
  if defined('$::puppetmaster') {
    $puppetmaster             = $::puppetmaster
  } else {
    $puppetmaster             = undef
  }

  # Will this host be a puppetmaster?
  $server_external_nodes           = "${dir}/node.rb"
  $server_certname                 = $::clientcert

  # Owner of the environments dir: for cases external service needs write
  # access to manage it.
  $server_environments_owner   = $server_user
  $server_environments_group   = $root_group
  # Where we store our puppet environments
  $server_envs_dir             = ["${codedir}/environments"]
  # Modules in this directory would be shared across all environments
  $server_common_modules_path  = unique(["${server_envs_dir[0]}/common", "${codedir}/modules", "${sharedir}/modules", '/usr/share/puppet/modules'])

  # Dynamic environments config, ignore if the git_repo is 'false'
  # Path to the repository
  $server_git_repo_path       = "${vardir}/puppet.git"
  # user of the repository
  $server_git_repo_user       = $server_user
  # group of the repository
  $server_git_repo_group      = $server_group

  $puppet_major = regsubst($::puppetversion, '^(\d+)\..*$', '\1')

  if ($facts['os']['family'] =~ /(FreeBSD|DragonFly)/) {
    $server_package = "puppetserver${puppet_major}"
  } else {
    $server_package = undef
  }

  $server_ssl_dir = $ssldir

  if $aio_package {
    $client_package = ['puppet-agent']
  } elsif ($facts['os']['family'] =~ /(FreeBSD|DragonFly)/) {
    $client_package = ["puppet${puppet_major}"]
  } else {
    $client_package = ['puppet']
  }

  # Puppet service name
  $service_name = 'puppet'

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
  $server_puppet_basedir   = $aio_package ? {
    true  => '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet',
    false => undef,
  }
  $server_foreman_url      = "https://${lower_fqdn}"

  # puppet server configuration file
  $server_jvm_config = $facts['os']['family'] ? {
    'RedHat' => '/etc/sysconfig/puppetserver',
    'Debian' => '/etc/default/puppetserver',
    default  => '/etc/default/puppetserver',
  }

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

  $server_admin_api_whitelist             = [ 'localhost', $lower_fqdn ]
  $server_ca_client_whitelist             = [ 'localhost', $lower_fqdn ]
  $server_cipher_suites                   = [
    'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256',
    'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
    'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
    'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
    'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
    'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
  ]

  # Puppetserver metrics shipping
  $server_metrics_server_id         = $lower_fqdn
}
