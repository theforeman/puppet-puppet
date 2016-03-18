define puppet::config::master (
  $value,
  $key    = $name,
  $joiner = ','
) {
  puppet::config::entry{"master_${name}":
    key          => $key,
    value        => $value,
    joiner       => $joiner,
    section      => 'master',
    sectionorder => 3,
  }
}
