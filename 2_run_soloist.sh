#!/bin/bash
set -e

# Start the ssh-agent and save the information; we'll need it later
SSH_AGENT=$(ssh $IMAGE_USER@$IMAGE_HOST ssh-agent)

function run_via_ssh() {
  cmd=$1
  echo "Running: '$cmd'"
  ssh $IMAGE_USER@$IMAGE_HOST "$cmd"
}

ssh $IMAGE_USER@$IMAGE_HOST "
  eval $SSH_AGENT
  ssh-add  ~/.ssh/id_github_private ;
  ( ssh -o StrictHostKeyChecking=no git@github.com exit; : ) &&
  cd /tmp &&
  git clone https://github.com/pivotal-sprout/sprout-orchard.git &&
  git clone $SPROUT_WRAP_GIT_URL sprout-wrap"

if [[ $PIVOTAL_LABS != "0" ]]; then
  ssh $IMAGE_USER@$IMAGE_HOST "
    eval $SSH_AGENT
    cd /tmp &&
    git clone git@github.com:pivotal/pivotal_workstation_private.git &&
    echo 'cookbook '\''pivotal_workstation_private'\'', :path => '\''/tmp/pivotal_workstation_private'\''' >> /tmp/sprout-wrap/Cheffile"
fi

NOKOGIRI_INSTALL='mkdir /tmp/libiconv
  cd /tmp/libiconv
  curl -OL http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz
  tar xvfz libiconv-1.13.1.tar.gz
  cd libiconv-1.13.1
  ./configure --prefix=/usr/local/Cellar/libiconv/1.13.1
  make
  sudo make install
  sudo gem install nokogiri -- --with-iconv-include=/usr/local/Cellar/libiconv/1.13.1/include --with-iconv-lib=/usr/local/Cellar/libiconv/1.13.1/lib'

run_via_ssh 'sudo pmset sleep 0' # prevent machine from sleeping (otherwise will lose build)
run_via_ssh 'sudo gem update --system'
run_via_ssh 'sudo gem install bundler --no-rdoc --no-ri'
run_via_ssh "$NOKOGIRI_INSTALL"
run_via_ssh 'cd /tmp/sprout-wrap && sudo bundle install && bundle exec soloist''
#  curl -LO https://github.com/pivotal-sprout/omnibus-soloist/releases/download/1.0.1/install.sh &&
#  sudo bash install.sh &&
#  PATH+=:/opt/soloist/bin/ &&
#  cd /tmp/sprout-wrap &&
#  soloist"

if [[ $PIVOTAL_LABS != "0" ]]; then
  ssh $IMAGE_USER@$IMAGE_HOST "
    eval $SSH_AGENT
    PATH+=:/opt/soloist/bin/
    cd /tmp/sprout-wrap &&
    bundle exec soloist run_recipe meta::pivotal_specifics &&
    bundle exec soloist run_recipe pivotal_workstation_private::meta_lion_image"
  # Successful run, in the future we should tag
fi

# post-install, set the machine name to NEWLY_IMAGED
ssh $IMAGE_USER@$IMAGE_HOST 'sudo hostname NEWLY_IMAGED
  sudo scutil --set ComputerName   NEWLY_IMAGED
  sudo scutil --set LocalHostName  NEWLY_IMAGED
  sudo scutil --set HostName       NEWLY_IMAGED
  sudo diskutil rename /           NEWLY_IMAGED'

run_via_ssh 'sudo cp /tmp/sprout-orchard/assets/com.pivotallabs.first_run.plist  /Library/LaunchAgents/'
run_via_ssh 'mkdir ~/bin; sudo cp /tmp/sprout-orchard/assets/first_run.rb /usr/sbin/'
run_via_ssh 'mkdir ~/bin; sudo cp /tmp/sprout-orchard/assets/auto_set_hostname.rb /usr/sbin/'

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

# FIXME: this shouldn't be necessary
run_via_ssh 'sudo diskutil mount $(diskutil list | grep Persistent | awk "{print \$6}")'

# reboot to Persistent
run_via_ssh 'sudo bless --mount /Volumes/Persistent --setboot'
run_via_ssh 'rm -fr ~/.ssh/id_github_private ~/.ssh/authorized_keys && sudo shutdown -r now'
