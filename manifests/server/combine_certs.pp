# combine the public x509 certificate and private key into one file
#
define puppet::server::combine_certs(
  $combined = undef,
  $cert     = undef,
  $key      = undef,
) {
  $dir = dirname($combined)

  $file_cert = file($cert)
  $file_key  = file($key)

  file { $dir:
    ensure => directory,
  }

  file { $combined:
    ensure  => file,
    content => "${file_cert}${file_key}",
  }
}
