#!/bin/bash
set -e
# IMAGE_PLATFORM is the OS X release, e.g. "Lion", "ML"
export IMAGE_PLATFORM=ML
# IMAGE_DIR is the directory of the location of the DeployStudio's
# master images as seen from the "persistent" personality of the 
# OS X build machine.  It should have ".dmg" files in it.  You should
# be able to type "ls $IMAGE_DIR/*.dmg" and see all the DeployStudio
# master images.
export IMAGE_DIR=/Volumes/DeployStudio/Masters/HFS
# IMAGE_USER is the user on the OS X build machine.  Jenkins should be able to
# ssh in to the OS X build machine as this user without a password, so make
# sure you have set up your ssh keys beforehand.  Also, this user needs to be
# able to run sudo without a password. 
export IMAGE_USER=imager
# IMAGE_HOST is the name of the OS X build machine.  Jenkins needs to be able
# to ssh into this machine (i.e. "ssh $IMAGE_USER@$IMAGE_HOST" from the
# Jenkins machine (i.e. sshd should be running & not be blocked by firewall
# rules).
export IMAGE_HOST=buildmachine-vm
# DEPLOYSTUDIO_SSH_KEYFILE is the ssh keyfile that the OS X build machine uses
# to connect to the DeployStudio machine 
export DEPLOYSTUDIO_SSH_KEYFILE=/Users/${IMAGE_USER}/.ssh/id_apple_orchard
# DEPLOYSTUDIO_DESTDIR is the pathname to the DeployStudio master images
# AS SEEN FROM THE DEPLOYSTUDIO SERVER.
export DEPLOYSTUDIO_DESTDIR=/Volumes/PivotLand/DeployStudio/Masters/HFS
# This is the user/host combination for the OS X build server to connect
# to the DeployStudio server with a userid with appropriate permissions 
# to cp/mv/rm master images.  The OS X build server should be able to
# "ssh -i $DEPLOYSTUDIO_SSH_KEYFILE $DEPLOYSTUDIO_USER_HOST ls $DEPLOYSTUDIO_DESTDIR"
export DEPLOYSTUDIO_USER_HOST=deploy@deploystudio
# If you're Pivotal Labs, set this to 1
export PIVOTAL_LABS=0
# If you need to build a different branch of pivotal_workstation
export GIT_BRANCH=master
echo "=========================="
echo "RESETTING MACHINE"
echo "=========================="
./1_reset_machine.rb
echo "=========================="
echo "RUNNING SOLOIST"
echo "=========================="
./2_run_soloist.sh
echo "=========================="
echo "REBOOTING TO PERSISTENT"
echo "=========================="
./3_reboot_to_persistent.rb
echo "=========================="
echo "TAKING IMAGE"
echo "=========================="
./4_take_image.rb
