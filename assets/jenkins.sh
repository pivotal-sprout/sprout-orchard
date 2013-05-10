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
# able to run sudo without a password. This user should be the primary
# workstation user (because much of the configuration is only for this
# user)
export IMAGE_USER=pivotal

# IMAGE_HOST is the name of the OS X build machine.  Jenkins needs to be able
# to ssh into this machine (i.e. "ssh $IMAGE_USER@$IMAGE_HOST" from the
# Jenkins machine (i.e. sshd should be running & not be blocked by firewall
# rules).
export IMAGE_HOST=buildmachine-vm

# If you're Pivotal Labs, set this to 1
export PIVOTAL_LABS=0

# If you want notification email(s) when image is created
# EMAIL_ADDR="nono@nono.com"
# EMAIL_ADDR="first_addr@nono.com second_addr@nono.com"
export EMAIL_ADDR=""

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
