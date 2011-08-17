#!/usr/bin/env ruby

def on_persistent?
  system("ssh pivotal@bacon.flood.pivotallabs.com -o ConnectTimeout=5 '[[ -d /Volumes/bacon ]]'")
end

def reboot_to(volume)
  puts("rebooting to #{volume}")
  system("ssh pivotal@bacon.flood.pivotallabs.com 'sudo bless --mount #{volume} --setboot'")
  system("ssh pivotal@bacon.flood.pivotallabs.com 'sudo shutdown -r now'")
end

unless on_persistent?
  reboot_to("/Volumes/Persistent")
  Timeout::timeout(120) do
    until on_persistent?
      sleep 1
    end   
  end
end

def system!(cmd)
  if ! system(cmd)
    raise "#{cmd}: #{$?.exitstatus}"
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

reboot_to("/Volumes/bacon")

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
