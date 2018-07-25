# combine the public x509 certificate and private key into one file
#
define puppet::server::combine_certs(
  $combined = $::puppet::server::passenger::ssl_combined,
  $cert     = $::puppet::server::ssl_cert,
  $key      = $::puppet::server::ssl_cert_key,
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
