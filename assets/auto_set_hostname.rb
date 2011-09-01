#!/usr/bin/env ruby
hostnames=[`hostname`.chop]

# block until the network comes up
`ipconfig waitall`
real_interfaces = `netstat -ni`.split("\n").select {|line| line.match(/en.*((\d+\.){3}\d+)/) }
host_ips = real_interfaces.collect {|line| line.match(/en.*?((\d+\.){3}\d+)/); Regexp.last_match(1) }
host_ips.each do |ip|
  hostnames << Socket.gethostbyaddr(ip.split(/\./).collect! {|i| i.to_i }.pack('CCCC'))[0]
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
