#!/usr/bin/env ruby
# set up one-time autorun

date=`date +%Y-%m-%d_%H-%M`.chop

puts "removing now-useless .curlrc"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo rm /Volumes/NEWLY_IMAGED/{var/root,Users/#{ENV['IMAGER_USER']}}/.curlrc'")
puts "Setting Pivotal Workstation release date"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'echo #{date} | sudo tee /Volumes/NEWLY_IMAGED/etc/pivotal_workstation_release'")
puts "clear out old #{IMAGE_PLATFORM}.dmg"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} '[[ -d /Volumes/NEWLY_IMAGED ]] && [[ -f #{IMAGE_PLATFORM}.dmg ]] && rm #{IMAGE_PLATFORM}.dmg'")
puts "create new #{IMAGE_PLATFORM}.dmg"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo hdiutil create -srcfolder /Volumes/NEWLY_IMAGED #{IMAGE_PLATFORM}.dmg'")
puts "imagescan new #{IMAGE_PLATFORM}.dmg for restore"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo asr imagescan --allowfragmentedcatalog --source #{IMAGE_PLATFORM}.dmg'")
puts "remove old #{IMAGE_PLATFORM}_HEAD from DeployStudio Masters"

# FIXME: This is tortured (jenkins ssh-ing to build-machine to ssh to DeployStudio).  Maybe using a share with
# correct permissions?
unless ENV['DEPLOYSTUDIO_SSH_KEYFILE'].nil? || ENV['DEPLOYSTUDIO_DESTDIR'].nil? || ENV['DEPLOYSTUDIO_USER_HOST'].nil?
  system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'ssh -i #{ENV['DEPLOYSTUDIO_SSH_KEYFILE']} #{ENV['DEPLOYSTUDIO_USER_HOST']} rm #{ENV['DEPLOYSTUDIO_DESTDIR']}/#{IMAGE_PLATFORM}_HEAD.i386.hfs.dmg'")
  puts "remove all but the two most recent snapshots"
  system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'ssh -i #{ENV['DEPLOYSTUDIO_SSH_KEYFILE']} #{ENV['DEPLOYSTUDIO_USER_HOST']} \"/bin/ls -cr  #{ENV['DEPLOYSTUDIO_DESTDIR']}/#{IMAGE_PLATFORM}_[0-9]*1[1-9]-*.i386.hfs.dmg | tail -n +2 | xargs rm\"'")
  puts "copy the new timestamped image & link to #{IMAGE_PLATFORM}_HEAD"
  system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} ' scp -i #{ENV['DEPLOYSTUDIO_SSH_KEYFILE']} #{IMAGE_PLATFORM}.dmg \
    #{ENV['DEPLOYSTUDIO_USER_HOST']}:#{ENV['DEPLOYSTUDIO_DESTDIR']}/#{IMAGE_PLATFORM}_#{date}.i386.hfs.dmg;
    ssh -i #{ENV['DEPLOYSTUDIO_SSH_KEYFILE']} #{ENV['DEPLOYSTUDIO_USER_HOST']} \
    \"cd #{ENV['DEPLOYSTUDIO_DESTDIR']}/; ln -s #{IMAGE_PLATFORM}_{#{date},HEAD}.i386.hfs.dmg;\"'")
end
