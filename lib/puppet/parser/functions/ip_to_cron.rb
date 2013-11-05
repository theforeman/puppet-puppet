# provides a "random" value to cron based on the last bit of the machine IP address.
# used to avoid starting a certain cron job at the same time on all servers.
# takes the runinterval in seconds as parameter and return an array of [hour, minute]
#
# example usage
# ip_to_cron(3600) - returns [ '*', one value between 0..59 ]
# ip_to_cron(1800) - returns [ '*', an array of two values between 0..59 ]
# ip_to_cron(7200) - returns [ an array of twelve values between 0..23, one value between 0..59 ]
module Puppet::Parser::Functions
  newfunction(:ip_to_cron, :type => :rvalue) do |args|
    runinterval = (args[0] || 30).to_i
    ip          = lookupvar('ipaddress').to_s.split('.')[3].to_i
    if runinterval <= 3600
      occurances = 3600 / runinterval
      scope = 60
      base = ip % scope
      hour = '*'
      minute = (1..occurances).map { |i| (base - (scope / occurances * i)) % scope }.sort
    else
      occurances = 86400 / runinterval
      scope = 24
      base = ip % scope
      hour = (1..occurances).map { |i| (base - (scope / occurances * i)) % scope }.sort
      minute = ip % 60
    end
    [ hour, minute ]
  end
end
