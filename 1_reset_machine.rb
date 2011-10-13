#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), "lib/util.rb")
include Util

unless on_persistent?
  reboot_to("/Volumes/Persistent")
  # You did name your other drive "bacon", didn't you?
  Timeout::timeout(120) do
    until on_persistent?
      sleep 1
    end
  end
end

puts "detaching"
# don't check return code; it says it failed even when it succeeds
system("ssh pivotal@bacon 'sudo hdiutil detach /dev/disk0s2'")
puts "restoring clean image"
system!("ssh pivotal@bacon 'sudo asr restore --buffers 1 --buffersize 32m --source /Volumes/DeployStudio/Masters/HFS/lion_mostly_pristine.i386.hfs.dmg  --erase --noprompt --target /dev/disk0s2'")
puts "attaching disk0s2 again"
system!("ssh pivotal@bacon 'sudo hdiutil attach /dev/disk0s2'")
puts "renaming restored image to 'bacon'"
system!("ssh pivotal@bacon 'sudo diskutil renameVolume /dev/disk0s2 bacon'")
puts "turning off spotlight on /Volumes/bacon"
system!("ssh pivotal@bacon 'sudo mdutil -i off /Volumes/bacon'")
puts "putting ssh-keys into place"
system!("ssh pivotal@bacon 'cp -Rp .ssh /Volumes/bacon/Users/pivotal/'")
puts "now putting sudoers that doesn't ask for a password'"
system!("ssh pivotal@bacon 'sudo cp {,/Volumes/bacon}/private/etc/sudoers'")
puts "turn on sshd"
system!("ssh pivotal@bacon 'sudo cp /etc/ssh* /Volumes/bacon/etc/; sudo defaults write /Volumes/bacon/var/db/launchd.db/com.apple.launchd/overrides.plist com.openssh.sshd -dict Disabled -bool false'")
system!("ssh pivotal@bacon 'echo --silent > /Volumes/bacon/Users/pivotal/.curlrc'")
# bit-shift to increase randomness (worried polling on the minute would make modules always fail or always succeed)
now = Time.new.to_i << 2
if now % 3 != 0
  system("ssh pivotal@bacon 'sudo mkdir -p /Volumes/bacon/var/chef/cache; sudo chown pivotal:admin /Volumes/bacon/var/chef/cache'")
  system("rsync -aH --stats /var/chef/cache/ pivotal@bacon:/var/chef/cache/")
  system("rsync -aH --stats ~/Library/Caches/Homebrew pivotal@bacon:/Volumes/bacon/Users/pivotal/Library/Caches/")
end
reboot_to("/Volumes/bacon")

disappear_reappear
