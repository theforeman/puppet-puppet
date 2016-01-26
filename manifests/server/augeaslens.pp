class puppet::server::augeaslens {
  file { "${puppet::server_lenses_dir}/trapperkeeper.aug":
    ensure  => file,
    owner   => 'root',
    group   => $::puppet::params::root_group,
    mode    => '0644',
    content => file("${module_name}/lenses/trapperkeeper.aug"),
  }
}
