define puppet::config::main (
  $value,
  $key    = $name,
  $joiner = ','
) {
  puppet::config::entry{"main${name}":
    key          => $key,
    value        => $value,
    joiner       => $joiner,
    section      => 'main',
    sectionorder => 1,
  }
}
