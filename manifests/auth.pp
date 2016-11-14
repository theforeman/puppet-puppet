# == Define: puppet::auth
#
# === Parameters
#
# [*name*]
#   String::            Name of the auth directive
#
# [*path*]
#   String::            Which URLs the ACL applies to. Required. Must be the first directive in the ACL.
#                       Default: the value of $name
#
# [*environment*]
#   String::            A valid environment or a comma-separated list of environments. Optional;
#                       defaults to all environments if omitted.
#
# [*method*]
#   String::            Which HTTP methods the ACL applies to.
#                       Allowed values: find, search, save, destroy, or a comma-separated list of those values. Optional;
#                       defaults to all methods if omitted.
#
# [*auth*]
#   String::            Whether the ACL applies to client-verified or non-client-verified HTTPS requests.
#                       Allowed values: yes, any, no (with on and off as synonyms). Must be a single value. Optional;
#                       defaults to yes (verified) if omitted.
#
# [*allow*]
#   String::            Which certificate names or hostnames can make requests that match the ACL.
#                       For client-verified requests, Puppet will check allow directives against the common name (CN)
#                       from the client's SSL certificate. For unverified requests, Puppet will use reverse DNS to figure
#                       out the client's hostname, and compare that to the allow directives.
#                       Optional; if you don't specify any allow or allow_ip directives, Puppet will reject all requests matching the ACL.
#
# [*deny*]
#   String::            The oposite of allow
#
# [*allow_ip*]
#   String::            Which IP addresses can make matching requests.
#
# [*deny_ip*]
#   String::            The oposite of allow_ip
#
define puppet::auth (
  $path                = $name,
  $order               = 20,
  $environment         = undef,
  $method              = undef,
  $auth                = undef,
  $allow               = undef,
  $deny                = undef,
  $allow_ip            = undef,
  $deny_ip             = undef,
  $auth_template_extra = 'puppet/auth_extra.conf.erb',
) {
  concat::fragment { "${name}_auth":
    target  => "${::puppet::dir}/auth.conf",
    content => template($auth_template_extra),
    order   => "${order}_${name}",
  }
}
