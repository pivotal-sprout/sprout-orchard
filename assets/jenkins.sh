#!/bin/bash
set -e
export IMAGE_PLATFORM=ML
# IMAGE_PLATFORM is the OS X release, e.g. "Lion", "ML"
export IMAGE_DIR=/Volumes/DeployStudio/Masters/HFS
# IMAGE_DIR is the directory of the location of the DeployStudio's
# master images as seen from the "persistent" personality of the 
# OS X build machine.  It should have ".dmg" files in it.  You should
# be able to type "ls $IMAGE_DIR/*.dmg" and see all the DeployStudio
# master images.
export IMAGER_USER=imager
# IMAGER_USER is the user on the OS X build machine.  Jenkins should be able to
# ssh in to the OS X build machine as this user without a password, so make
# sure you have set up your ssh keys beforehand.  Also, this user needs to be
# able to run sudo without a password. 
export IMAGER_HOST=buildmachine-vm
# IMAGER_HOST is the name of the OS X build machine.  Jenkins needs to be able
# to ssh into this machine (i.e. "ssh $IMAGER_USER@$IMAGER_HOST" from the
# Jenkins machine (i.e. sshd should be running & not be blocked by firewall
# rules).
export DEPLOYSTUDIO_SSH_KEYFILE=/Users/imager/.ssh/id_apple_orchard
# DEPLOYSTUDIO_SSH_KEYFILE is the ssh keyfile that the OS X build machine uses
# to connect to the DeployStudio machine 
export DEPLOYSTUDIO_DESTDIR=/Volumes/PivotLand/DeployStudio/Masters/HFS
# DEPLOYSTUDIO_DESTDIR is the pathname to the DeployStudio master images
# AS SEEN FROM THE DEPLOYSTUDIO SERVER.
export DEPLOYSTUDIO_USER_HOST=deploy@deploystudio
# This is the user/host combination for the OS X build server to connect
# to the DeployStudio server with a userid with appropriate permissions 
# to cp/mv/rm master images.  The OS X build server should be able to
# "ssh -i $DEPLOYSTUDIO_SSH_KEYFILE $DEPLOYSTUDIO_USER_HOST ls $DEPLOYSTUDIO_DESTDIR"
export PIVOTAL_LABS=0
# If you're Pivotal Labs, set this to 1
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
