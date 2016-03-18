define puppet::config::agent (
  $value,
  $key    = $name,
  $joiner = ','
) {
  puppet::config::entry{"agent_${name}":
    key          => $key,
    value        => $value,
    joiner       => $joiner,
    section      => 'agent',
    sectionorder => 2,
  }
}
