#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), "lib/util.rb")
include Util

image_user = ENV['IMAGE_USER'];
image_platform = ENV['IMAGE_PLATFORM'];
image_user_at_host = image_user + '@' + ENV['IMAGE_HOST']

# test ssh working
puts "test if ssh-without-password is working"
system!("ssh #{image_user_at_host} 'true'")

def rename_volume(old_name, new_name)
  system("ssh #{image_user_at_host} diskutil rename /Volumes/#{old_name} #{new_name}")
end

def find_partition(name)
  `ssh #{image_user_at_host} diskutil list`.each_line.map {|line| line =~ /#{name}/ && "/dev/"+line.split[5] }.compact.first
end

puts "determining imaging partition"
$persistent_partition = find_partition "Persistent"
$newly_imaged_partition = find_partition "NEWLY_IMAGED"
if !$newly_imaged_partition
  # Assume a recipe renamed 'NEWLY_IMAGED' disk to the hostname
  # we're going to set it back to 'NEWLY_IMAGED'
  rename_volume(ENV['IMAGE_HOST'],"NEWLY_IMAGED")
  $newly_imaged_partition = find_partition "NEWLY_IMAGED"
  if !$newly_imaged_partition
    puts "'diskutil list' couldn't find a partition /Volumes/#{name}"
    puts "try 'sudo diskutil rename /Volumes/blah_blah #{name}' to fix"
    exit 1
  end
end



unless on_persistent?
  reboot_to("/Volumes/Persistent")
  # You did name your other drive "NEWLY_IMAGED", didn't you?
  Timeout::timeout(120) do
    until on_persistent?
      sleep 1
    end
  end
end

# allow time for automated login & mounting of disks to work
# We need AT LEAST a minute for the disk to mount
sleep 90
puts "detaching (unmounting) #{$newly_imaged_partition} imaging partition"
# ignore spurious 'hdiutil: couldn't unmount "disk0" - Resource busy' messages
system("ssh #{image_user_at_host} 'sudo hdiutil detach #{$newly_imaged_partition}'")
puts "restoring clean image from #{ENV['IMAGE_DIR']}/#{image_platform}_mostly_pristine.i386.hfs.dmg"
system!("ssh #{image_user_at_host} 'sudo asr restore --format hfs+ --allowfragmentedcatalog --buffers 1 --buffersize 32m --source #{ENV['IMAGE_DIR']}/#{image_platform}_mostly_pristine.i386.hfs.dmg  --erase --noprompt --target #{$newly_imaged_partition}'")
puts "attaching (mounting) #{$newly_imaged_partition} again"
system!("ssh #{image_user_at_host} 'sudo hdiutil attach #{$newly_imaged_partition}'")
puts "renaming restored image to 'NEWLY_IMAGED'"
system!("ssh #{image_user_at_host} 'sudo diskutil renameVolume #{$newly_imaged_partition} NEWLY_IMAGED'")
puts "turning off spotlight on /Volumes/NEWLY_IMAGED"
system!("ssh #{image_user_at_host} 'sudo mdutil -i off /Volumes/NEWLY_IMAGED'")
puts "putting ssh-keys into place"
system!("ssh #{image_user_at_host} 'mkdir /Volumes/NEWLY_IMAGED/Users/#{image_user}/.ssh'")
system!("ssh #{image_user_at_host} 'chmod 700 /Volumes/NEWLY_IMAGED/Users/#{image_user}/.ssh'")
system!("ssh #{image_user_at_host} 'cp .ssh/id_github_private /Volumes/NEWLY_IMAGED/Users/#{image_user}/.ssh'")
system!("ssh #{image_user_at_host} 'cp .ssh/authorized_keys /Volumes/NEWLY_IMAGED/Users/#{image_user}/.ssh'")
puts "now putting sudoers that doesn't ask for a password"
system!("ssh #{image_user_at_host} 'sudo cp {,/Volumes/NEWLY_IMAGED}/private/etc/sudoers'")
puts "turn on sshd"
system!("ssh #{image_user_at_host} 'sudo cp /etc/ssh* /Volumes/NEWLY_IMAGED/etc/; sudo defaults write /Volumes/NEWLY_IMAGED/var/db/launchd.db/com.apple.launchd/overrides.plist com.openssh.sshd -dict Disabled -bool false'")
# The screensaver serves no purpose other than to senselessly chew up CPU, unnecessarily burning watts
system!("ssh #{image_user_at_host} 'sudo defaults write /Volumes/NEWLY_IMAGED/Library/Preferences/com.apple.screensaver.plist moduleDict -dict moduleName iLifeSlideshows path \"/System/Library/Frameworks/ScreenSaver.framework/Resources/iLifeSlideshows.saver\" type -int 0'")
system!("ssh #{image_user_at_host} 'echo --silent > /Volumes/NEWLY_IMAGED/Users/#{image_user}/.curlrc'")
system!("ssh #{image_user_at_host} 'echo --silent | sudo tee /Volumes/NEWLY_IMAGED/var/root/.curlrc'")
# bit-shift to increase randomness (worried polling on the minute would make modules always fail or always succeed)
now = Time.new.to_i << 2
if now % 3 != 0
  system("ssh #{image_user_at_host} 'sudo mkdir -p /Volumes/NEWLY_IMAGED/var/chef/cache; sudo chown #{image_user}:admin /Volumes/NEWLY_IMAGED/var/chef/cache'")
  system("rsync -aH --stats /var/chef/cache/ #{image_user_at_host}:/Volumes/NEWLY_IMAGED/var/chef/cache/")
  system("rsync -aH --stats /Library/Caches/Homebrew #{image_user_at_host}:/Volumes/NEWLY_IMAGED/Library/Caches/")
end
reboot_to("/Volumes/NEWLY_IMAGED")

disappear_reappear
