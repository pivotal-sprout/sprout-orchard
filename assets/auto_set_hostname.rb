#!/usr/bin/env ruby
hostnames=[`hostname`.chop]

require 'socket'
`netstat -ni`.split(/\n/).each do |line|
  # we don't need the column header
  next if /^Name / === line
  # we don't care about the vmware interfaces
  next if /^vmnet/ === line
  # ... nor do we care about the firewire interfaces
  next if /^fw/ === line
  fields = line.split
  # The address is the 4th field (fields[3])
  # but sometimes there is NO address, which means
  # fields[3] is sometimes the 5th field!
  # To determine whether fields[3] is the 4th or 5th
  # field, we see if it's an integer:
  #   integer => 5th field (e.g. '0')
  #   non-integer => 4th field (address, e.g. "172.17.8.5")
  next if /^[\d]+$/ === fields[3]
  # let's skip the mac addrs & ip6 addresses
  next if /:/ === fields[3]
  hostnames << Socket.gethostbyaddr(fields[3].split(/\./).collect! {|i| i.to_i }.pack('CCCC'))[0]
end

print "hostnames: "
p hostnames
hostnames.each do |hostname|
  if hostname =~ /pivotallabs.com/ and hostname !~ /^dyn-/
    hostname = hostname.gsub(/\..*/,"")
    # The scutil commands need to run as root, unless
    # you're logged into the console, but we can't be sure of that.
    `sudo scutil --set ComputerName #{hostname}`
    `sudo scutil --set LocalHostName #{hostname}`
    `sudo scutil --set HostName #{hostname}`
    `sudo hostname #{hostname}`
    `diskutil rename / #{hostname}`
  end
end

# We now remove ourselves (we only want to run once)
# We move ourselves to .Trash instead of rm'ing in case the
# sysadmin wants to run this script again (e.g. ethernet wasn't
# plugged in when the machine is booted).
pivot_home="/Users/pivotal"
`mv #{pivot_home}/bin #{pivot_home}/.Trash`
`sudo mv /Library/LaunchAgents/com.pivotallabs.auto_set_hostname.plist #{pivot_home}/.Trash`
`sudo chown -R pivotal #{pivot_home}/.Trash`
