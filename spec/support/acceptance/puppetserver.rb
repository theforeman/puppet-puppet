def unsupported_puppetserver
  host_inventory['facter']['os']['name'] == 'Fedora'
end
