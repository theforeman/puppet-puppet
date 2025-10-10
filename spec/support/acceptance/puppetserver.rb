def unsupported_puppetserver
  case host_inventory['facter']['os']['name']
  when 'Archlinux'
    true
  when 'Fedora'
    true
  end
end

def unsupported_puppetserver_upgrade
  case host_inventory['facter']['os']['name']
  when 'Archlinux'
    true
  when 'Fedora'
    true
  when 'Debian'
    ENV['BEAKER_PUPPET_COLLECTION'] == 'puppet8' && host_inventory['facter']['os']['release']['major'] == '12'
  end
end
