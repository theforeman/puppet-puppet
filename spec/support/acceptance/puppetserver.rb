def unsupported_puppetserver
  os = host_inventory['facter']['os']
  case os['family']
  when 'Archlinux'
    true
  when 'Debian'
    os['name'] == 'Debian' && os['release']['major'] == '12'
  when 'RedHat'
    # puppetserver uses PIDFile, which breaks on Docker
    os['name'] == 'Fedora' || (default[:hypervisor] == 'docker' && os['release']['major'] == '8')
  end
end

def unsupported_puppetserver_upgrade
  # currently none
  false
end
