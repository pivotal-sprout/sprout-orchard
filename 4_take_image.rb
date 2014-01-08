#!/usr/bin/env ruby
# set up one-time autorun

image_user = ENV['IMAGE_USER']
image_platform = ENV['IMAGE_PLATFORM']
image_dir = ENV['IMAGE_DIR']
image_user_at_host = image_user + '@' + ENV['IMAGE_HOST']
email_addr = ENV['EMAIL_ADDR']

date=`date +%Y-%m-%d_%H-%M`.chop

# allow time for automated login & mounting of disks to work
# We need AT LEAST a minute for the disk to mount
sleep 90

def run_command(command)
  puts "Running: #{command}"
  output = `#{command}`
  exit_code = $?
  puts "       Output: #{output}"
  puts "    Exit Code: #{exit_code}"
end

puts "removing now-useless .curlrc"
run_command("ssh #{image_user_at_host} 'sudo rm /Volumes/NEWLY_IMAGED/{var/root,Users/#{image_user}}/.curlrc'")
puts "Setting Pivotal Workstation release date"
run_command("ssh #{image_user_at_host} 'echo #{date} | sudo tee /Volumes/NEWLY_IMAGED/etc/pivotal_workstation_release'")
puts "clear out old #{image_platform}.dmg"
run_command("ssh #{image_user_at_host} '[[ -d /Volumes/NEWLY_IMAGED ]] && [[ -f #{image_platform}.dmg ]] && rm #{image_platform}.dmg'")
puts "create new #{image_platform}.dmg"
run_command("ssh #{image_user_at_host} 'sudo hdiutil create -fs HFS+J -srcfolder /Volumes/NEWLY_IMAGED #{image_platform}.dmg'")
puts "imagescan new #{image_platform}.dmg for restore"
run_command("ssh #{image_user_at_host} 'sudo asr imagescan --allowfragmentedcatalog --source #{image_platform}.dmg'") || exit(1)
puts "remove old #{image_platform}_HEAD from DeployStudio Masters"

puts "remove the existing #{image_dir}/#{image_platform}_HEAD.i386.hfs.dmg"
run_command("ssh #{image_user_at_host} rm #{image_dir}/#{image_platform}_HEAD.i386.hfs.dmg")
puts "remove all but the two most recent snapshots"
run_command("ssh #{image_user_at_host} '/bin/ls -cr  #{image_dir}/#{image_platform}_[0-9]*1[1-9]-*.i386.hfs.dmg | tail -n +2 | xargs rm'")
puts "copy the new timestamped image & link to #{image_platform}_HEAD"
run_command("ssh #{image_user_at_host} 'cp #{image_platform}.dmg #{image_dir}/#{image_platform}_#{date}.i386.hfs.dmg; cd #{image_dir}/; ln -s #{image_platform}_{#{date},HEAD}.i386.hfs.dmg;'")

run_command("echo '#{image_platform}_#{date}.i386.hfs.dmg' | mail -s 'New DeployStudio Image' #{email_addr}") if email_addr
