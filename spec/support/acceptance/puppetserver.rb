def unsupported_puppetserver
  case host_inventory['facter']['os']['name']
  when 'Fedora'
    true
  when 'Ubuntu'
    ENV['BEAKER_PUPPET_COLLECTION'] == 'puppet6' && host_inventory['facter']['os']['release']['major'] == '20.04'
  end
end
