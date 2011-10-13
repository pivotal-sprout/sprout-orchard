#!/usr/bin/env ruby
# set up one-time autorun

puts "removing now-useless .curlrc"
system("rm /Volumes/NEWLY_IMAGED/{var/root,Users/pivotal}/.curlrc")
puts "copying set-machine-name script into place"
system("scp",__FILE__.sub(/\/[^\/]*$/,"")  + "/assets/auto_set_hostname.rb","pivotal@bacon.flood.pivotallabs.com:/Volumes/NEWLY_IMAGED/Users/pivotal/bin/auto_run.command")
#set -e
puts "clear out old lion.dmg"
`ssh pivotal@bacon.flood.pivotallabs.com '[[ -d /Volumes/NEWLY_IMAGED ]] && [[ -f lion.dmg ]] && rm lion.dmg'`
puts "create new lion.dmg"
`ssh pivotal@bacon.flood.pivotallabs.com 'sudo hdiutil create -srcfolder /Volumes/NEWLY_IMAGED lion.dmg'`
puts "imagescan new lion.dmg for restore"
`ssh pivotal@bacon.flood.pivotallabs.com 'sudo asr imagescan --source lion.dmg'`
puts "remove old lion_HEAD from DeployStudio Masters"
`ssh pivotal@bacon.flood.pivotallabs.com 'ssh -i /Users/pivotal/.ssh/id_union_deploy deploy@union rm /Volumes/PivotLand/DeployStudio/Masters/HFS/lion_HEAD.i386.hfs.dmg'`
puts "remove all but the two most recent bacon snapshots"
`ssh pivotal@bacon.flood.pivotallabs.com 'ssh -i /Users/pivotal/.ssh/id_union_deploy deploy@union "/bin/ls -cr  /Volumes/PivotLand/DeployStudio/Masters/HFS/lion_1[1-9]-*.i386.hfs.dmg | tail -n +2 | xargs rm"'`
#set -e
date=`date +%y-%m-%d_%H-%M`.chop
puts "copy the new timestamped bacon image & link to lion_HEAD"
`ssh pivotal@bacon.flood.pivotallabs.com ' scp -i /Users/pivotal/.ssh/id_union_deploy lion.dmg \
    deploy@union:/Volumes/PivotLand/DeployStudio/Masters/HFS/lion_#{date}.i386.hfs.dmg;
  ssh -i /Users/pivotal/.ssh/id_union_deploy deploy@union \
    "cd /Volumes/PivotLand/DeployStudio/Masters/HFS/; ln -s lion_{#{date},HEAD}.i386.hfs.dmg;"'`
