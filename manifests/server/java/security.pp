# A class to set java security providers.
class puppet::server::java::security (
  $filename = '/etc/java-8-openjdk/security/java.security',
  $bouncy_castle_package = 'libbcprov-java',
  $security_providers = [
    'sun.security.provider.Sun',
    'org.bouncycastle.jce.provider.BouncyCastleProvider',
    'sun.security.rsa.SunRsaSign',
    'sun.security.ec.SunEC',
    'com.sun.net.ssl.internal.ssl.Provider',
    'com.sun.crypto.provider.SunJCE',
    'sun.security.jgss.SunProvider',
    'com.sun.security.sasl.Provider',
    'org.jcp.xml.dsig.internal.dom.XMLDSigRI',
    'sun.security.smartcardio.SunPCSC',
  ],
) {
  package { $bouncy_castle_package:
    ensure => installed,
  }

  $security_providers.each |$index, $provider| {
    $number = $index + 1
    $setting = "security.provider.${number}"
    ini_setting { $setting:
      ensure  => present,
      path    => $filename,
      setting => $setting,
      value   => $provider,
      require => Package['libbcprov-java'],
    }
  }
}
