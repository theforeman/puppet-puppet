def unsupported_puppetserver
  case host_inventory['facter']['os']['name']
  when 'Archlinux'
    true
  when 'Fedora'
    true
  end
end
