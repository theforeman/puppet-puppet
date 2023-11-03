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

# These versions only have a single version (x.y.z) released so no upgrade is possible
def unsupported_puppetserver_upgrade
  (fact('os.family') == 'RedHat' && fact('os.release.major') == '9') ||
    (fact('os.name') == 'Ubuntu' && fact('os.release.major') == '22.04')
end
