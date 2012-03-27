#!/usr/bin/env ruby
# set up one-time autorun

date=`date +%Y-%m-%d_%H-%M`.chop

puts "removing now-useless .curlrc"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo rm /Volumes/NEWLY_IMAGED/{var/root,Users/#{ENV['IMAGER_USER']}}/.curlrc'")
puts "Setting Pivotal Workstation release date"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'echo #{date} | sudo tee /Volumes/NEWLY_IMAGED/etc/pivotal_workstation_release'")
puts "clear out old lion.dmg"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} '[[ -d /Volumes/NEWLY_IMAGED ]] && [[ -f lion.dmg ]] && rm lion.dmg'")
puts "create new lion.dmg"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo hdiutil create -srcfolder /Volumes/NEWLY_IMAGED lion.dmg'")
puts "imagescan new lion.dmg for restore"
system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'sudo asr imagescan --allowfragmentedcatalog --source lion.dmg'")
puts "remove old lion_HEAD from DeployStudio Masters"

unless ENV['DEPLOYSTUDIO_SSH_KEYFILE'].nil? || ENV['DEPLOYSTUDIO_DESTDIR'].nil? || ENV['DEPLOYSTUDIO_USER_HOST'].nil?
  system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'ssh -i #{ENV['DEPLOYSTUDIO_SSH_KEYFILE']} #{ENV['DEPLOYSTUDIO_USER_HOST']} rm #{ENV['DEPLOYSTUDIO_DESTDIR']}/lion_HEAD.i386.hfs.dmg'")
  puts "remove all but the two most recent snapshots"
  system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} 'ssh -i /Users/#{ENV['IMAGER_USER']}/.ssh/id_union_deploy #{ENV['DEPLOYSTUDIO_USER_HOST']} \"/bin/ls -cr  #{ENV['DEPLOYSTUDIO_DESTDIR']}/lion_[0-9]*1[1-9]-*.i386.hfs.dmg | tail -n +2 | xargs rm\"'")
  puts "copy the new timestamped image & link to lion_HEAD"
  system("ssh #{ENV['IMAGER_USER']}@#{ENV['IMAGER_HOST']} ' scp -i /Users/#{ENV['IMAGER_USER']}/.ssh/id_union_deploy lion.dmg \
    #{ENV['DEPLOYSTUDIO_USER_HOST']}:#{ENV['DEPLOYSTUDIO_DESTDIR']}/lion_#{date}.i386.hfs.dmg;
    ssh -i /Users/#{ENV['IMAGER_USER']}/.ssh/id_union_deploy #{ENV['DEPLOYSTUDIO_USER_HOST']} \
    \"cd #{ENV['DEPLOYSTUDIO_DESTDIR']}/; ln -s lion_{#{date},HEAD}.i386.hfs.dmg;\"'")
end
