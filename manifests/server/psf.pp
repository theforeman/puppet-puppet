class puppet::server::psf (
  String[1] $package_name = 'psf',
  String[1] $package_ensure = 'installed',
  Boolean $enc = true,
  Boolean $facts = true,
  Boolean $report = true,
) {
  package { $package_name:
    ensure => $package_ensure,
  }

  if $package_ensure != 'absent' {
    {
      'enc'    => $enc,
      'facts'  => $facts,
      'report' => $report,
    }.each |$service, $ensure| {
      service { "psfd@${service}.socket":
        ensure  => $enc,
        enable  => $enc,
        require => Package[$package_name],
      }
      ~> service { "psfd@${service}.service":
        subscribe => File <| title == '/etc/foreman-proxy/settings.yml' |>,
      }
    }
  }
}
