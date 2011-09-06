#!/usr/bin/env ruby
# set up one-time autorun
system("scp",__FILE__.sub(/\/[^\/]*$/,"")  + "/assets/auto_set_hostname.rb","/Volumes/bacon/Users/pivotal/bin/auto_run.command")
#set -e
`ssh pivotal@bacon.flood.pivotallabs.com '[[ -d /Volumes/bacon ]] && [[ -f lion.dmg ]] && rm lion.dmg'`
`ssh pivotal@bacon.flood.pivotallabs.com 'sudo hdiutil create -srcfolder /Volumes/bacon lion.dmg'`
`ssh pivotal@bacon.flood.pivotallabs.com 'sudo asr imagescan --source lion.dmg'`
#set +e
`ssh pivotal@bacon.flood.pivotallabs.com 'ssh -i /Users/pivotal/.ssh/id_union_deploy deploy@union rm /Volumes/PivotLand/DeployStudio/Masters/HFS/lion_HEAD.i386.hfs.dmg'`
`ssh pivotal@bacon.flood.pivotallabs.com 'ssh -i /Users/pivotal/.ssh/id_union_deploy deploy@union "/bin/ls -cr  /Volumes/PivotLand/DeployStudio/Masters/HFS/lion_1[1-9]-*.i386.hfs.dmg | tail -n +2 | xargs rm"'`
#set -e
`ssh pivotal@bacon.flood.pivotallabs.com 'export DATE=$(date +%y-%m-%d_%H-%M);
  scp -i /Users/pivotal/.ssh/id_union_deploy lion.dmg \
    deploy@union:/Volumes/PivotLand/DeployStudio/Masters/HFS/lion_${DATE}.i386.hfs.dmg;
  ssh -i /Users/pivotal/.ssh/id_union_deploy deploy@union \
    cd /Volumes/PivotLand/DeployStudio/Masters/HFS/; ln -s lion_{${DATE},HEAD}.i386.hfs.dmg;'`
