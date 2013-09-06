#!/usr/bin/env ruby
require 'socket'

hostnames=[`hostname`.chop]

# block until the network comes up
`ipconfig waitall`
# let's wait a few seconds for the network interface to settle
sleep 10
real_interfaces = `netstat -ni`.split("\n").select {|line| line.match(/en.*((\d+\.){3}\d+)/) }
host_ips = real_interfaces.collect {|line| line.match(/en.*?((\d+\.){3}\d+)/); Regexp.last_match(1) }
host_ips.each do |ip|
  begin
    hostnames << Socket.gethostbyaddr(ip.split(/\./).collect! {|i| i.to_i }.pack('CCCC'))[0]
  rescue SocketError
    p "no reverse lookup for \"#{ip}\""
  end
end

def set_hostname(hostname)
  # The scutil commands need to run as root, unless
  # you're logged into the console, but we can't be sure of that.
  puts "Setting machine's hostname to \"#{hostname}\""
  `sudo scutil --set ComputerName #{hostname}`
  `sudo scutil --set LocalHostName #{hostname}`
  `sudo scutil --set HostName #{hostname}`
  `sudo hostname #{hostname}`
  `diskutil rename / #{hostname}`
  
  `echo 'g/HOSTNAME/d
  wq
  '|sudo ed /etc/hostconfig`
  
end

hostnames.each do |hostname|
  if hostname =~ /pivotallabs.com/ and hostname !~ /^dyn-/
    hostname = hostname.gsub(/\..*/,"")
    set_hostname hostname
  end
end


