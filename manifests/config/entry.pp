define puppet::config::entry (
  $key,
  $value,
  $section,
  $sectionorder = 5,
  $joiner       = ',',
) {
  if is_array($value) {
    $_value = join(flatten($value), $joiner)
  } elsif is_bool($value) {
    $_value = bool2str($value)
  } else {
    $_value = $value
  }

  # note the spaces at he end of the 'order' parameters,
  # they make sure that '1_main ' is ordered before '1_main_*'
  ensure_resource('concat_fragment', "puppet.conf_${section}", {
    target  => "${::puppet::dir}/puppet.conf",
    content => "\n\n[${section}]",
    order   => "${sectionorder}_${section} ",
    tag     => 'concat_file_puppet.conf',
  })

  # this adds the '$key =' for the first value,
  # otherwise it just appends it with the joiner to separate it from the previous value.
  if (!defined(Concat_fragment["puppet.conf_${section}_${key}"])){
    concat_fragment{"puppet.conf_${section}_${key}":
      target  => "${::puppet::dir}/puppet.conf",
      content => "\n    ${key} = ${_value}",
      order   => "${sectionorder}_${section}_${key} ",
      tag     => 'concat_file_puppet.conf',
    }
  } else {
    concat_fragment{"puppet.conf_${section}_${key}_${name}":
      target  => "${::puppet::dir}/puppet.conf",
      content => "${joiner}${_value}",
      order   => "${sectionorder}_${section}_${key}_${name} ",
      tag     => 'concat_file_puppet.conf',
    }
  }
}
