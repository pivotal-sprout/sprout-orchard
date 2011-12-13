#!/bin/bash
set -e

ssh pivotal@bacon.flood.pivotallabs.com 'mkdir -p ~/workspace'
ssh pivotal@bacon.flood.pivotallabs.com 'eval `ssh-agent` && 
  ssh-add  ~/.ssh/id_github_lion && 
  cd workspace && 
  git clone https://github.com/pivotal/pivotal_workstation.git && 
  pushd /pivotal_workstation &&
  git remote set-url origin https://github.com/pivotal/pivotal_workstation.git &&
  popd
  git clone git@github.com:pivotalprivate/pivotal_workstation_private.git && 
  pushd pivotal_workstation_private &&
  git remote set-url origin https://pivotalcommon@github.com/pivotalprivate/pivotal_workstation_private.git &&
  popd &&
  git clone git@github.com:pivotalexperimental/apple_orchard.git'

ssh pivotal@bacon.flood.pivotallabs.com 'cat > soloistrc <<EOF
cookbook_paths:
- workspace
recipes:
- pivotal_workstation::meta_pivotal_lion_image
- pivotal_workstation_private::meta_lion_image
EOF
'

ssh pivotal@bacon.flood.pivotallabs.com 'gem list | grep soloist || sudo gem install soloist'
ssh pivotal@bacon.flood.pivotallabs.com 'soloist'

# post-install, set the machine name to NEWLY_IMAGED
ssh pivotal@bacon.flood.pivotallabs.com 'sudo hostname NEWLY_IMAGED
  sudo scutil --set ComputerName   NEWLY_IMAGED
  sudo scutil --set LocalHostName  NEWLY_IMAGED
  sudo scutil --set HostName       NEWLY_IMAGED
  sudo diskutil rename /           NEWLY_IMAGED'

ssh pivotal@bacon.flood.pivotallabs.com 'sudo cp ~/workspace/apple_orchard/assets/com.pivotallabs.auto_set_hostname.plist  /Library/LaunchAgents/'
ssh pivotal@bacon.flood.pivotallabs.com 'mkdir ~/bin; cp ~/workspace/apple_orchard/assets/auto_set_hostname.rb /usr/sbin/'

ssh pivotal@bacon.flood.pivotallabs.com 'sudo bless --mount /Volumes/Persistent --setboot'
ssh pivotal@bacon.flood.pivotallabs.com 'rm -fr ~/.ssh; sudo shutdown -r now'
