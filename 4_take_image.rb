#!/usr/bin/env ruby
# set up one-time autorun

image_user = ENV['IMAGE_USER'];
image_platform = ENV['IMAGE_PLATFORM'];
image_user_at_host = image_user + '@' + ENV['IMAGE_HOST']

date=`date +%Y-%m-%d_%H-%M`.chop

puts "removing now-useless .curlrc"
system("ssh #{image_user_at_host} 'sudo rm /Volumes/NEWLY_IMAGED/{var/root,Users/#{ENV['IMAGE_USER']}}/.curlrc'")
puts "Setting Pivotal Workstation release date"
system("ssh #{image_user_at_host} 'echo #{date} | sudo tee /Volumes/NEWLY_IMAGED/etc/pivotal_workstation_release'")
puts "clear out old #{image_platform}.dmg"
system("ssh #{image_user_at_host} '[[ -d /Volumes/NEWLY_IMAGED ]] && [[ -f #{image_platform}.dmg ]] && rm #{image_platform}.dmg'")
puts "create new #{image_platform}.dmg"
system("ssh #{image_user_at_host} 'sudo hdiutil create -fs HFS+J -srcfolder /Volumes/NEWLY_IMAGED #{image_platform}.dmg'")
puts "imagescan new #{image_platform}.dmg for restore"
system("ssh #{image_user_at_host} 'sudo asr imagescan --allowfragmentedcatalog --source #{image_platform}.dmg'")
puts "remove old #{image_platform}_HEAD from DeployStudio Masters"

puts "remove the existing #{ENV['IMAGE_DIR']}/#{image_platform}_HEAD.i386.hfs.dmg"
system("ssh #{image_user_at_host} rm #{ENV['IMAGE_DIR']}/#{image_platform}_HEAD.i386.hfs.dmg")
puts "remove all but the two most recent snapshots"
system("ssh #{image_user_at_host} '/bin/ls -cr  #{ENV['IMAGE_DIR']}/#{image_platform}_[0-9]*1[1-9]-*.i386.hfs.dmg | tail -n +2 | xargs rm'")
puts "copy the new timestamped image & link to #{image_platform}_HEAD"
system("ssh #{image_user_at_host} 'cp #{image_platform}.dmg #{ENV['IMAGE_DIR']}/#{image_platform}_#{date}.i386.hfs.dmg; cd #{ENV['IMAGE_DIR']}/; ln -s #{image_platform}_{#{date},HEAD}.i386.hfs.dmg;'")
