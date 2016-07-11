define puppet::config::additional_settings(
  $hash,
  $resource,
  $key = $title,
  $options = {},
){
  create_resources($resource, {
      "${key}" => {
        value => $hash[$key],
      }
    }, $options)
}
