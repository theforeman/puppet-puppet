# Set a config entry
#
# @param key
#   The key of the config entry
# @param value
#   The value for the config entry
# @param section
#   The section for the config entry
# @param sectionorder
#   How to order the section. This is only used on the first definition of the
#   section via ensure_resource.
# @param joiner
#   How to join an array value into a string
define puppet::config::entry (
  String $key,
  Variant[Array[Variant[String,Sensitive[String]]], Boolean, String, Integer, Sensitive[String]] $value,
  String $section,
  Variant[Integer[0], String] $sectionorder = 5,
  String $joiner       = ',',
) {
  if ($value =~ Array) {
    $_value = join(flatten($value), $joiner)
  } elsif ($value =~ Boolean) {
    $_value = bool2str($value)
  } else {
    $_value = $value
  }

  # note the spaces at he end of the 'order' parameters,
  # they make sure that '1_main ' is ordered before '1_main_*'
  ensure_resource('concat::fragment', "puppet.conf_${section}", {
      target  => "${puppet::dir}/puppet.conf",
      content => "\n[${section}]",
      order   => "${sectionorder}_${section} ",
  })
  ensure_resource('concat::fragment', "puppet.conf_${section}_end", {
      target  => "${puppet::dir}/puppet.conf",
      content => "\n",
      order   => "${sectionorder}_${section}~end",
  })

  # this adds the '$key =' for the first value,
  # otherwise it just appends it with the joiner to separate it from the previous value.
  if (!defined(Concat::Fragment["puppet.conf_${section}_${key}"])) {
    concat::fragment { "puppet.conf_${section}_${key}":
      target  => "${puppet::dir}/puppet.conf",
      content => "\n    ${key} = ${_value}",
      order   => "${sectionorder}_${section}_${key} ",
    }
  } else {
    concat::fragment { "puppet.conf_${section}_${key}_${name}":
      target  => "${puppet::dir}/puppet.conf",
      content => "${joiner}${_value}",
      order   => "${sectionorder}_${section}_${key}_${name} ",
    }
  }
}
