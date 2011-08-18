#!/bin/bash
set -e
ssh pivotal@bacon.flood.pivotallabs.com '[[ -d /Volumes/bacon ]]'
ssh pivotal@bacon.flood.pivotallabs.com 'sudo hdiutil create -srcfolder /Volumes/bacon lion.dmg'
ssh pivotal@bacon.flood.pivotallabs.com 'sudo asr imagescan --source lion.dmg'
set +e
ssh pivotal@bacon.flood.pivotallabs.com 'ssh -i /Users/pivotal/.ssh/id_union_deploy deploy@union /bin/ls -cr  /Volumes/PivotLand/DeployStudio/Masters/HFS/lion_{1[1-9]-*,HEAD}.i386.hfs.dmg | tail -n +3 | xargs echo rm'
set -e
ssh pivotal@bacon.flood.pivotallabs.com 'export DATE=$(date +%y-%m-%d_%H-%M);
  scp -i /Users/pivotal/.ssh/id_union_deploy lion.dmg \
    deploy@union:/Volumes/PivotLand/DeployStudio/Masters/HFS/lion_${DATE}.i386.hfs.dmg;
  ssh -i /Users/pivotal/.ssh/id_union_deploy deploy@union \
    ln /Volumes/PivotLand/DeployStudio/Masters/HFS/{lion_${DATE},lion_HEAD}.i386.hfs.dmg;'
