class puppet::agent::config {
  concat_fragment { 'puppet.conf+20-agent':
    content => template($puppet::agent_template),
  }
}
