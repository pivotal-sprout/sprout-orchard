# Run this script on the ci box, not the jenkins box
set -e

mkdir -p ~/cookbooks
cd ~/cookbooks

rm -rf ~/cookbooks/pivotal_workstation*
git clone git@github.com:pivotalprivate/pivotal_workstation_private.git
git clone https://github.com/pivotal/pivotal_workstation.git

sudo gem install chef
sudo gem install soloist

LOG_LEVEL=debug soloist
