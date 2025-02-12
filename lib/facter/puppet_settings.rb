require 'puppet'

Facter.add('puppet_confdir') do
  setcode do
    Puppet.settings['confdir']
  end
end
