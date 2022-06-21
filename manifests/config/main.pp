# Set a config entry in the [main] section
#
# @param value
#   The value for the config entry
# @param key
#   The key of the config entry
# @param joiner
#   How to join an array value into a string
define puppet::config::main (
  Variant[Array[String], Boolean, String, Integer] $value,
  String $key    = $name,
  String $joiner = ','
) {
  puppet::config::entry { "main${name}":
    key          => $key,
    value        => $value,
    joiner       => $joiner,
    section      => 'main',
    sectionorder => 1,
  }
}
