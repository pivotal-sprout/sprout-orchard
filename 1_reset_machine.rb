#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), "lib/util.rb")
include Util

unless on_persistent?
  reboot_to("/Volumes/Persistent")
  # You did name your other drive "NEWLY_IMAGED", didn't you?
  Timeout::timeout(120) do
    until on_persistent?
      sleep 1
    end
  end
end

puts "determining imaging partition"
disk_partition = `ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} diskutil list`.each_line.map {|line| line =~ /NEWLY_IMAGED/ && "/dev/"+line.split[5] }.compact.first
exit 1 if !disk_partition
puts "detaching (unmounting) #{disk_partition} imaging partition"
# ignore spurious 'hdiutil: couldn't unmount "disk0" - Resource busy' messages
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo hdiutil detach #{disk_partition}'")
puts "restoring clean image"
system!("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo asr restore --buffers 1 --buffersize 32m --source #{ENV['IMAGE_DIR']}/lion_mostly_pristine.i386.hfs.dmg  --erase --noprompt --target #{disk_partition}'")
puts "attaching (mounting) #{disk_partition} again"
system!("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo hdiutil attach #{disk_partition}'")
puts "renaming restored image to 'NEWLY_IMAGED'"
system!("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo diskutil renameVolume #{disk_partition} NEWLY_IMAGED'")
puts "turning off spotlight on /Volumes/NEWLY_IMAGED"
system!("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo mdutil -i off /Volumes/NEWLY_IMAGED'")
puts "putting ssh-keys into place"
system!("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'cp -Rp .ssh /Volumes/NEWLY_IMAGED/Users/#{ENV['IMAGER_USER']}/'")
puts "now putting sudoers that doesn't ask for a password'"
system!("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo cp {,/Volumes/NEWLY_IMAGED}/private/etc/sudoers'")
puts "turn on sshd"
system!("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo cp /etc/ssh* /Volumes/NEWLY_IMAGED/etc/; sudo defaults write /Volumes/NEWLY_IMAGED/var/db/launchd.db/com.apple.launchd/overrides.plist com.openssh.sshd -dict Disabled -bool false'")
system!("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'echo --silent > /Volumes/NEWLY_IMAGED/Users/#{ENV['IMAGER_USER']}/.curlrc'")
system!("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'echo --silent | sudo tee /Volumes/NEWLY_IMAGED/var/root/.curlrc'")
# bit-shift to increase randomness (worried polling on the minute would make modules always fail or always succeed)
now = Time.new.to_i << 2
if now % 3 != 0
  system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo mkdir -p /Volumes/NEWLY_IMAGED/var/chef/cache; sudo chown #{ENV['IMAGER_USER']}:admin /Volumes/NEWLY_IMAGED/var/chef/cache'")
  system("rsync -aH --stats /var/chef/cache/ #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']}:/Volumes/NEWLY_IMAGED/var/chef/cache/")
  system("rsync -aH --stats /Library/Caches/Homebrew #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']}:/Volumes/NEWLY_IMAGED/Library/Caches/")
end
reboot_to("/Volumes/NEWLY_IMAGED")

disappear_reappear
