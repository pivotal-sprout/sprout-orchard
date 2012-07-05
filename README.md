Apple Orchard: Scripts (bash & ruby) to support imaging of OSX machines

# Why?
We image OSX machines to use in conjunction with
[DeployStudio](http://www.deploystudio.com) in order to rapidly deploy developer
workstations.

# How do I set it up?
These instructions were tested under OS X Lion 10.7.4 and Xcode 4.3.3

## Initial Workstation Creation

 1. get a workstation.
	1. Boot from a Lion Install USB drive
	1. Choose **Disk Utility**; click **Continue**
	1. Use System Preferences to partition it into 2 partions (Partition Map Scheme: GUID Partition Table; Format: Mac OS Extended (Journaled))
	1. name the first one after the hostname (e.g. "**_bacon_**")
	1. name the second one "**NEWLY_IMAGED**"
	1. Click **Apply**
	1. **Cmd-Q** to quit Disk Utility.
 
 1. Install Lion on the Persistent partition
	1. Select **Reinstall Mac OS X**; Click **Continue**.
	1. Splash screen, click **Continue**.
	1. Click **Agree**.
	1. Click **Agree**, again.
	1. Select the **Persistent** partition; click **Install** (takes ~7-30 minutes).
	1. Select Country, e.g. ***United States***; click **Continue**.
	1. Select keyboard layout, e.g. ***U.S.***; click **Continue**.
	1. Select **Don't transfer now**; click **Continue**
   
	1. Enter Your Apple ID
	1. Type in your Apple ID, e.g. ***accounts+appstore@pivotallabs.com***
	1. Type in the password, e.g. ***Loves2dance***
	1. Click **Continue**
	1. Review your Registration; click **Continue**
   
	1. Fill out the **Create Your Computer Account**
		1. Full Name: e.g. ***pivotal***
		1. Account Name:  e.g. ***pivotal***
		1. Password:  e.g. ***loves2dance***
		1. Verify:  e.g. ***loves2dance***
		1. Uncheck **Allow my Apple ID...**
		1. Password Hint: e.g. ***How do you feel about dancing?***
		1. Click **Continue**
		1. Click **Start Using Lion**

	1. Log in as user
	1. Bring up a terminal
		1. Type **curl -LO https://github.com/downloads/kennethreitz/osx-gcc-installer/GCC-10.7-v2.pkg**
		1. Type **sudo installer -package *.pkg -target /**
		1. Type in your password
	1. Click on the **App Store** icon in the dock.
		1. Type **Xcode** in the search bar; press **return**.
		1. Click on the gray **Free** button in Xcode.  It will turn into a green **Install App** button; click that.
		1. Enter your App Store userid & password (i.e. your Apple Id).
		1. Click on the Xcode Icon
		1. Click **Agree** to Xcode License Agreement
		1. Click **Install** to Xcode Component Installation
		1. Type in your password; click **Install Software**
	1. Click **Start Using Xcode**
	1. Click **Xcode** &rarr; **Preferences** &rarr; **Downloads** &rarr; **Components**
	1. Select **Command Line Tools**; click **Install**
	1. Press **Cmd-Q** to quit Xcode.
 
	1. In your terminal window
		1. Type **sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer**
		1. Type **sudo softwareupdate -i -a**

	1. Bring up **Address Book**; remove the entry corresponding to the Appstore user (to avoid Chrome using that information to pre-populate address fields) (we want to minimize the personally-identifiable information)

	1. Create the mostly-pristine image on the DeployStudio server:
		1. Click **Apple Icon** &rarr; **Restart**; click **Restart**
		1. Hold down the **Option** key while rebooting.
		1. Select the DeployStudio Netboot.  You have set up a DeployStudio NetBoot server, haven't you?
		1. Click **Create a master from a volume**
		1. Press the **Play** button (looks like an arrow).
		1. On the Hard Drive dropdown, select **NEWLY_IMAGED**
		1. Image name, e.g. ***10.7.3_4.3.1_12.03.16_23.21***
		1. Press the **Play** button (looks like an arrow).
		1. When it's finished, you'll need to create a symbolic link on the DeployStudio server, in the Masters/HFS subdirectory, e.g.<br />**ln -s 10.7.3&#95;4.3&#95;12.02.23&#95;23.30.i386.hfs.dmg lion&#95;mostly&#95;pristine.i386.hfs.dmg**
		1. The machine will reboot when it has finished.
		1. Click **Restart** on the login screen.
		1. Hold down the **Option** key while it reboots.
		1. Select **Persistent**. Click the **&uarr;**.


	1. **ONLY IF YOU USE VMWARE**.  VMWare Fusion does not allow netbooting (as of 4.1.3).  If that is the case, you can still snapshot your image, but the process is more complex:
		1. Boot from the Install image, again.
		1. Bring up **Disk Utility**
		1. Select **NEWLY_IMAGED**
		1. Click **Restore**
		1. Drag-and-drop **Persistent** to Source:
		1. Drag-and-drop **NEWLY_IMAGED** to Destination:
		1. Click **Restore**
		1. Click **Erase**
		1. Click on the Apple in the upper-left-hand corner
		1. Click **Startup Disk...** 
		1. Select the first **Persistent** partition
		1. Click **Restart...**
		1. When it reboots, log in
		1. Bring up **Terminal**
		1. Type **sudo diskutil rename /Volumes/Persistent\ 1 NEWLY_IMAGED**
		1. Mount the DeployStudio server's hard drive.  
		1. Type **DESTFILE=*10.7.4-4.3.3*-$(date +%y.%m.%d-%H.%M).hfs.dmg**
		1. Type **sudo hdiutil create -srcfolder /Volumes/NEWLY_IMAGED /Volumes/DeployStudio/Masters/HFS/$DESTFILE**
		1. Type **sudo asr imagescan --allowfragmentedcatalog --source /Volumes/DeployStudio/Masters/HFS/$DESTFILE**
		1. Type **cd /Volumes/DeployStudio/Masters/HFS/; ln -sf $DESTFILE lion\_mostly\_pristine.i386.hfs.dmg**
		
	
## Setting up Jenkins

[Jenkins](http://jenkins-ci.org/) is an extendable open source continuous integration server.  This is how to set up Jenkins to kick off an automatic build of a new image every time a change is committed to the build cookbook(s).

 1. Install Jenkins
 1. Add the Git Plugin
 1. Create a new Jenkins Project
	1. Project name: **Workstation Image**
		1. Select **Git**
		1. URL of repository: **git://github.com/pivotalexperimental/apple_orchard.git**		
	1. Build Triggers
		1. Check **Build after other projects are built**
		1. Check **Poll SCM**
		1. Schedule **\* \* \* \* \***
	1. Build
		1. Execute shell Command:
<code>
	\#!/bin/bash
	set -e
	export IMAGE\_DIR=/Volumes/DeployStudio/Masters/HFS
	export IMAGER\_USER=pivotal
	export IMAGER\_HOST=bacon
	export DEPLOYSTUDIO\_SSH\_KEYFILE=/Users/pivotal/.ssh/id\_union\_deploy
	export DEPLOYSTUDIO\_DESTDIR=/Volumes/PivotLand/DeployStudio/Masters/HFS
	export DEPLOYSTUDIO\_USER\_HOST=deploy@union
	echo "=========================="
	echo "RESETTING MACHINE"
	echo "=========================="
	./1\_reset\_machine.rb
	echo "=========================="
	echo "RUNNING SOLOIST"
	echo "=========================="
	./2\_run\_soloist.sh
	echo "=========================="
	echo "REBOOTING TO PERSISTENT"
	echo "=========================="
	./3\_reboot\_to\_persistent.rb
	echo "=========================="
	echo "TAKING IMAGE"
	echo "=========================="
	./4\_take\_image.rb
</code>
    1. Explanation of shell variables:
       IMAGE\_DIR is the directory of the DeployStudio share as it's seen by the build machine.  If you do an ls in that directory, you should see the **lion\_mostly\_pristine.dmg**

	1. Project name: **Z Workstation Trigger**
	1. Source Code Management
		1. Select **Git**
		1. URL of repository: **git@github.com:pivotal/pivotal_workstation.git**
	1. Build Triggers
		1. Select **Poll SCM**
		1. Schedule **\* \* \* \* \***
		

1. DeployStudio
1. Click **Create a master from a volume**
1. Press the **Play** button (looks like an arrow).
1. On the Hard Drive dropdown, select **NEWLY_IMAGED**
1. Image name, e.g. ***10.7.3_4.3.1_12.03.16_23.21***
1. Press the **Play** button (looks like an arrow).
1. When it's finished, you'll need to create a symbolic link on the DeployStudio server, in the Masters/HFS subdirectory, e.g.<br />ln -s 10.7.3&#95;4.3&#95;12.02.23&#95;23.30.i386.hfs.dmg lion&#95;mostly&#95;pristine.i386.hfs.dmg
1. The machine will reboot when it has finished.
1. Click **Restart** on the login screen.
1. Hold down the **Option** key while it reboots.
1. Select **Persistent**. Click the **&uarr;**.
 1. Go to the Jenkins server; Click **Build Now** for your project.


## BUGS

This process doesn't capture recovery partitions (i.e. a newly-imaged machine won't have a recovery partition).  This doesn't seem to be a DeployStudio bug; rather, it appears to be the way in which we update images on DeployStudio.

The large majority of failures are from the DeployStudio share not mounted on boot by the "persistent" personality.

# To whom do we complain?
**apple_orchard** started as a side project of [Matthew
Kocher](https://github.com/mkocher) and [Brian
Cunnie](https://github.com/briancunnie) of Pivotal Labs in Summer 2011.
