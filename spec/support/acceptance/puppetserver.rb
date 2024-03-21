def unsupported_puppetserver
  case host_inventory['facter']['os']['name']
  when 'Archlinux'
    true
  when 'Fedora'
    true
  when 'Debian'
    host_inventory['facter']['os']['release']['major'] == '12'
  end
end

def unsupported_puppetserver_upgrade
  # currently none
  false
end
