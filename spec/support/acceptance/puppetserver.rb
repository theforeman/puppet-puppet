def unsupported_puppetserver
  case host_inventory['facter']['os']['name']
  when 'Fedora'
    true
  when 'Debian'
    ENV['BEAKER_PUPPET_COLLECTION'] == 'puppet5' && host_inventory['facter']['os']['distro']['codename'] == 'buster'
  when 'Ubuntu'
    ENV['BEAKER_PUPPET_COLLECTION'] == 'puppet6' && host_inventory['facter']['os']['distro']['codename'] == 'focal'
  end
end
