define puppet::config::master (
  Variant[Array[String], Boolean, String, Integer] $value,
  String $key    = $name,
  String $joiner = ','
) {
  puppet::config::entry{"master_${name}":
    key          => $key,
    value        => $value,
    joiner       => $joiner,
    section      => 'master',
    sectionorder => 3,
  }
}
