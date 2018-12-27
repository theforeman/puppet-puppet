define puppet::config::main (
  Variant[Array[String], Boolean, String, Integer] $value,
  String $key    = $name,
  String $joiner = ','
) {
  puppet::config::entry{"main${name}":
    key          => $key,
    value        => $value,
    joiner       => $joiner,
    section      => 'main',
    sectionorder => 1,
  }
}
