#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), "lib/util.rb")

unless Util.on_persistent?
  Util.reboot_to("/Volumes/Persistent")
  Timeout::timeout(120) do
    until Util.on_persistent?
      sleep 1
    end   
  end
end

puts "detaching"
# don't check return code; it says it failed even when it succeeds
system("ssh pivotal@bacon.flood.pivotallabs.com 'sudo hdiutil detach /dev/disk0s2'")
puts "restoring clean image"
system!("ssh pivotal@bacon.flood.pivotallabs.com 'sudo asr restore --buffers 1 --buffersize 32m --source Desktop/lion_ssh_sudo_autologin.dmg  --erase --noprompt --target /dev/disk0s2'")
puts "attaching disk0s2 again"
system!("ssh pivotal@bacon.flood.pivotallabs.com 'sudo hdiutil attach /dev/disk0s2'")
system!("ssh pivotal@bacon.flood.pivotallabs.com 'cp .ssh/authorized_keys2 /Volumes/bacon/Users/pivotal/.ssh/'")
system!("ssh pivotal@bacon.flood.pivotallabs.com 'cp assets/auto_run.command /Volumes/bacon/Users/pivotal/bin/'")

Util.reboot_to("/Volumes/bacon")

Util.disappear_reappear
