#!/usr/bin/env ruby

require 'timeout'

# wait for machine to disappear
Timeout::timeout(120) do
  if system("ssh pivotal@bacon.flood.pivotallabs.com -o ConnectTimeout=5 'true'")
    sleep 1
  end
end

puts "machine down"

# wait for machine to reappear
Timeout::timeout(120) do
  until system("ssh pivotal@bacon.flood.pivotallabs.com -o ConnectTimeout=5 'true'")
    sleep 1
  end
end

puts "machine back up"
