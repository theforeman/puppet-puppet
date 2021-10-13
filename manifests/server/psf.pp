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
    service { 'psfd@enc.socket':
      ensure  => $enc,
      enable  => $enc,
      require => Package[$package_name],
    }

    service { 'psfd@facts.socket':
      ensure  => $facts,
      enable  => $facts,
      require => Package[$package_name],
    }

    service { 'psfd@report.socket':
      ensure  => $report,
      enable  => $report,
      require => Package[$package_name],
    }
  }
}
