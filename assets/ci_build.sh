# Run this script on the ci box, not the jenkins box

# grab the github key, which will exit non-zero
ssh -o StrictHostKeyChecking=no git@github.com

# start watching for errors
set -e

mkdir -p ~/cookbooks
cd ~/cookbooks

rm -rf ~/cookbooks/pivotal_workstation*
# FIXME: the following line is pivotal-internal
git clone git@github.com:pivotalprivate/pivotal_workstation_private.git
git clone https://github.com/pivotal/pivotal_workstation.git

sudo gem install chef
sudo gem install soloist

LOG_LEVEL=debug soloist
