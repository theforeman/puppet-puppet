def unsupported_puppetserver
  os = host_inventory['facter']['os']
  case os['family']
  when 'Archlinux'
    true
  when 'Debian'
    os['name'] == 'Debian' && os['release']['major'] == '12'
  when 'RedHat'
    os['name'] == 'Fedora'
  end
end

def unsupported_puppetserver_upgrade
  # currently none
  false
end
