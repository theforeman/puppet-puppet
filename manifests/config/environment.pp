define puppet::config::environment (
  $env,
  $value,
  $key    = $name,
  $joiner = ','
) {
  puppet::config::entry{"${env}_${name}":
    key     => $key,
    value   => $value,
    joiner  => $joiner,
    section => $env,
  }
}
