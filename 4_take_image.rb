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
system("ssh #{image_user_at_host} 'sudo hdiutil create -srcfolder /Volumes/NEWLY_IMAGED #{image_platform}.dmg'")
puts "imagescan new #{image_platform}.dmg for restore"
system("ssh #{image_user_at_host} 'sudo asr imagescan --allowfragmentedcatalog --source #{image_platform}.dmg'")
puts "remove old #{image_platform}_HEAD from DeployStudio Masters"

# FIXME: This is tortured (jenkins ssh-ing to build-machine to ssh to DeployStudio).  Maybe using a share with
# correct permissions?
unless ENV['DEPLOYSTUDIO_SSH_KEYFILE'].nil? || ENV['DEPLOYSTUDIO_DESTDIR'].nil? || ENV['DEPLOYSTUDIO_USER_HOST'].nil?
  system("ssh #{image_user_at_host} 'ssh -i #{ENV['DEPLOYSTUDIO_SSH_KEYFILE']} #{ENV['DEPLOYSTUDIO_USER_HOST']} rm #{ENV['DEPLOYSTUDIO_DESTDIR']}/#{image_platform}_HEAD.i386.hfs.dmg'")
  puts "remove all but the two most recent snapshots"
  system("ssh #{image_user_at_host} 'ssh -i #{ENV['DEPLOYSTUDIO_SSH_KEYFILE']} #{ENV['DEPLOYSTUDIO_USER_HOST']} \"/bin/ls -cr  #{ENV['DEPLOYSTUDIO_DESTDIR']}/#{image_platform}_[0-9]*1[1-9]-*.i386.hfs.dmg | tail -n +2 | xargs rm\"'")
  puts "copy the new timestamped image & link to #{image_platform}_HEAD"
  system("ssh #{image_user_at_host} ' scp -i #{ENV['DEPLOYSTUDIO_SSH_KEYFILE']} #{image_platform}.dmg \
    #{ENV['DEPLOYSTUDIO_USER_HOST']}:#{ENV['DEPLOYSTUDIO_DESTDIR']}/#{image_platform}_#{date}.i386.hfs.dmg;
    ssh -i #{ENV['DEPLOYSTUDIO_SSH_KEYFILE']} #{ENV['DEPLOYSTUDIO_USER_HOST']} \
    \"cd #{ENV['DEPLOYSTUDIO_DESTDIR']}/; ln -s #{image_platform}_{#{date},HEAD}.i386.hfs.dmg;\"'")
end
