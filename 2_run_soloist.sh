#!/bin/bash
set -e

ssh $IMAGE_USER@$IMAGE_HOST "
  cd /tmp &&
  git clone https://github.com/pivotal-sprout/sprout-orchard.git &&
  eval `ssh-agent` &&
  ssh-add  ~/.ssh/id_github_private &&
  ( ssh -o StrictHostKeyChecking=no git@github.com exit; : ) &&
  git clone $SPROUT_WRAP_GIT_URL sprout-wrap"

if [[ $PIVOTAL_LABS ]]; then
  ssh $IMAGE_USER@$IMAGE_HOST 'eval `ssh-agent` &&
    ssh-add  ~/.ssh/id_github_private &&
    ( ssh -o StrictHostKeyChecking=no git@github.com exit; : ) &&
    cd /tmp &&
    git clone git@github.com:pivotal/pivotal_workstation_private.git &&
    echo "cookbook \"pivotal_workstation_private\", :path => \"/tmp/pivotal_workstation_private\"" >> /tmp/sprout-wrap/Cheffile'
fi

ssh $IMAGE_USER@$IMAGE_HOST 'sudo pmset sleep 0' # prevent machine from sleeping (otherwise will lose build)
ssh $IMAGE_USER@$IMAGE_HOST 'cd /tmp/sprout-wrap && sudo gem install bundler && bundle install && bundle exec soloist'

if [[ $PIVOTAL_LABS ]]; then
  ssh $IMAGE_USER@$IMAGE_HOST 'cd /tmp/sprout-wrap && bundle exec soloist run_recipe meta::pivotal_specifics'
  ssh $IMAGE_USER@$IMAGE_HOST 'cd /tmp/sprout-wrap && bundle exec soloist run_recipe pivotal_workstation_private::meta_lion_image'

  # Successful run, in the future we should tag
fi

# post-install, set the machine name to NEWLY_IMAGED
ssh $IMAGE_USER@$IMAGE_HOST 'sudo hostname NEWLY_IMAGED
  sudo scutil --set ComputerName   NEWLY_IMAGED
  sudo scutil --set LocalHostName  NEWLY_IMAGED
  sudo scutil --set HostName       NEWLY_IMAGED
  sudo diskutil rename /           NEWLY_IMAGED'

ssh $IMAGE_USER@$IMAGE_HOST 'sudo cp /tmp/sprout-orchard/assets/com.pivotallabs.first_run.plist  /Library/LaunchAgents/'
ssh $IMAGE_USER@$IMAGE_HOST 'mkdir ~/bin; sudo cp /tmp/sprout-orchard/assets/first_run.rb /usr/sbin/'
ssh $IMAGE_USER@$IMAGE_HOST 'mkdir ~/bin; sudo cp /tmp/sprout-orchard/assets/auto_set_hostname.rb /usr/sbin/'

# turn off vmware tools (VMware Shared Folders) if installed
ssh $IMAGE_USER@$IMAGE_HOST 'for PLIST in \
  /Library/LaunchAgents/com.vmware.launchd.vmware-tools-userd.plist \
  /Library/LaunchDaemons/com.vmware.launchd.tools.plist
do
  [ -f $PLIST ] &&
  sudo defaults write $PLIST RunAtLoad -bool false &&
  sudo plutil -convert xml1 $PLIST &&
  sudo chmod 444 $PLIST
done
rm ~/Desktop/VMWare\ Shared\ Folders
true'

# reboot to Persistent
ssh $IMAGE_USER@$IMAGE_HOST 'sudo bless --mount /Volumes/Persistent --setboot'
ssh $IMAGE_USER@$IMAGE_HOST 'rm -fr ~/.ssh/id_github_private ~/.ssh/authorized_keys && sudo shutdown -r now'
