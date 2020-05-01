def unsupported_puppetserver
  host_inventory['facter']['os']['name'] == 'Fedora' ||
    (host_inventory['facter']['os']['name'] == 'Ubuntu' && host_inventory['facter']['os']['distro']['codename'] == 'focal')
end
