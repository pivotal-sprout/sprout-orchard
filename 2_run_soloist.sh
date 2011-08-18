#!/bin/bash
set -e

ssh pivotal@bacon.flood.pivotallabs.com 'mkdir -p ~/workspace'
ssh pivotal@bacon.flood.pivotallabs.com 'eval `ssh-agent` && ssh-add  ~/.ssh/id_github_lion && cd workspace && git clone git@github.com:pivotal/pivotal_workstation.git && git clone git@github.com:pivotalprivate/pivotal_workstation_private.git'

ssh pivotal@bacon.flood.pivotallabs.com 'cat > soloistrc <<EOF
cookbook_paths:
- workspace
recipes:
- pivotal_workstation::lion_basedev
- pivotal_workstation_private::lion_basedev
EOF
'

ssh pivotal@bacon.flood.pivotallabs.com 'gem list | grep soloist || sudo gem install soloist'
ssh pivotal@bacon.flood.pivotallabs.com 'soloist'

# clean-up
ssh pivotal@bacon.flood.pivotallabs.com 'defaults delete com.apple.loginitems'
ssh pivotal@bacon.flood.pivotallabs.com 'rm -fr ~/bin'

ssh pivotal@bacon.flood.pivotallabs.com 'sudo bless --mount /Volumes/Persistent --setboot'
ssh pivotal@bacon.flood.pivotallabs.com 'rm -fr ~/.ssh; sudo shutdown -r now'
