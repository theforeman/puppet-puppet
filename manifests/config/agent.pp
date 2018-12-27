define puppet::config::agent (
  Variant[Array[String], Boolean, String, Integer] $value,
  String $key    = $name,
  String $joiner = ','
) {
  puppet::config::entry{"agent_${name}":
    key          => $key,
    value        => $value,
    joiner       => $joiner,
    section      => 'agent',
    sectionorder => 2,
  }
}
