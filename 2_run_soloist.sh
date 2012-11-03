#!/bin/bash
set -e

ssh $IMAGE_USER@$IMAGE_HOST 'mkdir -p ~/cookbooks; mkdir -p ~/workspace'
ssh $IMAGE_USER@$IMAGE_HOST "cd cookbooks &&
  git clone https://github.com/pivotal/pivotal_workstation.git && 
  git clone https://github.com/opscode-cookbooks/dmg.git && 
  cd pivotal_workstation &&
  git checkout $GIT_BRANCH &&
  cd ~/workspace &&
  git clone https://github.com/pivotalexperimental/apple_orchard.git"


ssh $IMAGE_USER@$IMAGE_HOST 'cat > soloistrc <<EOF
cookbook_paths:
- cookbooks
recipes:
- pivotal_workstation::meta_osx_base
- pivotal_workstation::meta_osx_development
- pivotal_workstation::meta_ruby_development
EOF
'

if [[ $PIVOTAL_LABS ]]; then
  ssh $IMAGE_USER@$IMAGE_HOST 'eval `ssh-agent` && 
    ssh-add  ~/.ssh/id_github_lion && 
    pushd cookbooks &&
    ( ssh -o StrictHostKeyChecking=no git@github.com exit; : ) && 
    git clone git@github.com:pivotalprivate/pivotal_workstation_private.git && 
    pushd pivotal_workstation_private &&
    git remote set-url origin https://pivotalcommon@github.com/pivotalprivate/pivotal_workstation_private.git &&
    popd && popd &&
    echo "- pivotal_workstation::meta_pivotal_specifics"  >> ~/soloistrc &&
    echo "- pivotal_workstation_private::meta_lion_image" >> ~/soloistrc'
fi

ssh $IMAGE_USER@$IMAGE_HOST 'gem list | grep chef || sudo gem install chef'
ssh $IMAGE_USER@$IMAGE_HOST 'gem list | grep soloist || sudo gem install soloist'
ssh $IMAGE_USER@$IMAGE_HOST 'soloist'

# post-install, set the machine name to NEWLY_IMAGED
ssh $IMAGE_USER@$IMAGE_HOST 'sudo hostname NEWLY_IMAGED
  sudo scutil --set ComputerName   NEWLY_IMAGED
  sudo scutil --set LocalHostName  NEWLY_IMAGED
  sudo scutil --set HostName       NEWLY_IMAGED
  sudo diskutil rename /           NEWLY_IMAGED'

ssh $IMAGE_USER@$IMAGE_HOST 'sudo cp ~/workspace/apple_orchard/assets/com.pivotallabs.auto_set_hostname.plist  /Library/LaunchAgents/'
ssh $IMAGE_USER@$IMAGE_HOST 'mkdir ~/bin; sudo cp ~/workspace/apple_orchard/assets/auto_set_hostname.rb /usr/sbin/'

# turn off vmware tools (VMware Shared Folders) if installed
ssh $IMAGE_USER@$IMAGE_HOST 'PLIST=/Library/LaunchAgents/com.vmware.launchd.vmware-tools-userd.plist; 
  [ -f $PLIST ] && 
  sudo defaults write $PLIST RunAtLoad -bool false &&
  sudo plutil -convert xml1 $PLIST &&
  sudo chmod 444 $PLIST
  rm ~/Desktop/VMWare\ Shared\ Folders
  true'

# reboot to Persistent
ssh $IMAGE_USER@$IMAGE_HOST 'sudo bless --mount /Volumes/Persistent --setboot'
ssh $IMAGE_USER@$IMAGE_HOST 'rm -fr ~/.ssh; sudo shutdown -r now'
