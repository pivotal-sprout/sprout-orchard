Apple Orchard: Scripts (bash & ruby) to support imaging of OSX machines

# Why?
We image OSX machines to use in conjunction with
[DeployStudio](http://www.deploystudio.com) in order to rapidly deploy developer
workstations.

# How do I set it up?
These instructions were tested under OS X Lion and Xcode 4.3.

 1. get a workstation.
 1. Use System Preferences to partition it into 2 partions (Partition Map Scheme: GUID Partition Table; Format: Mac OS Extended (Journaled))
 1. name the first one after the hostname (e.g. "**_bacon_**")
 1. name the second one "**NEWLY_IMAGED**"
 1. Load the OS onto the first partition.
 1. Load the OS onto the second partition.
 1. Boot from a Lion Install USB drive
 1. Choose **Disk Utility**
 1. Select the "**NEWLY_IMAGED**" partition in the navbar on the left.
 1. Click the **Erase** tab.
 1. Click the **Erase...** button.
 1. Click the **Erase** button on the dialogue box.
 1. **Cmd-Q** to quit Disk Utility.
 
 1. Select **Reinstall Mac OS X**; Click **Continue**.
 1. Splash screen, click **Continue**.
 1. Click **Agree**.
 1. Click **Agree**, again.
 1. Select the **NEWLY_IMAGED** partition; click **Install** (takes ~7-30 minutes).
 1. Select Country, e.g. ***United States***; click **Continue**.
 1. Select keyboard layout, e.g. ***U.S.***; click **Continue**.
 1. Select **Don't transfer now**; click **Continue**
 
 1. Enter Your Apple ID
  1. Type in your Apple ID, e.g. ***accounts+appstore@pivotallabs.com***
  1. Type in the password, e.g. ***Loves2dance***
  1. Click **Continue**
  1. Review your Registration; click **Continue**
 
 1. Fill out the **Create Your Computer Account**
  1. Full Name: e.g. ***Pivotal User***
  1. Account Name:  e.g. ***pivotal***
  1. Password:  e.g. ***loves2dance***
  1. Verify:  e.g. ***loves2dance***
  1. Uncheck **Allow my Apple ID...**
  1. Password Hint: e.g. ***How do you feel about dancing?***
  1. Click **Continue**
  
 1. Select a Picture for this account
  1. Select **Choose from the picture library**
  1. Select the Red Rose; it's pretty.
  1. Click **Continue**
  1. Select the appropriate timezone.
  1. Click **Continue**
  1. Scroll to the bottom of the text and click **Start using Mac OS X Lion**.
 
 1. Log in as user
 1. Click on the **App Store** icon in the dock.
 1. Type **Xcode** in the search bar; press **return**.
 1. Click on the gray **Free** button in Xcode.  It will turn into a green **Install App** button; click that.
 1. Click on the Xcode Icon
 1. Click **Agree** (to the license).
 1. Click **Install** (to the component installation)
 1. Type in your password; click **Install Software**
 1. Click **Start Using Xcode**
 1. Click **Xcode** &rarr; **Preferences** &rarr; **Downloads** &rarr; **Components**
 1. Select **Command Line Tools**; click **Install**
 1. Enter your [Apple Developer](https://developer.apple.com/) credentials; uncheck **Remember this password**.
 1. Press **Cmd-Q** to quit Xcode.

 1. Click **Apple Icon** &rarr; **Restart**; click **Restart**
 1. Hold down the **Option** key while rebooting.
 1. Select the DeployStudio Netboot.  You have set up a DeployStudio NetBoot server, haven't you?
 1. Click the **&uarr;**

 1. DeployStudio
  1. Click **Create a master from a volume**
  1. Press the **Play** button (looks like an arrow).
  1. On the Hard Drive dropdown, select **NEWLY_IMAGED**
  1. Image name, e.g. ***10.7.3_4.3_12.02.23_23.21***
  1. Press the **Play** button (looks like an arrow).
  1. When it's finished, you'll need to create a symbolic link on the DeployStudio server, in the Masters/HFS subdirectory, e.g.<br />ln -s 10.7.3&#95;4.3&#95;12.02.23&#95;23.30.i386.hfs.dmg lion&#95;mostly&#95;pristine.i386.hfs.dmg
  1. The machine will reboot when it has finished.
 1. Click **Restart** on the login screen.
 1. Hold down the **Option** key while it reboots.
 1. Select **Persistent**. Click the **&uarr;**.
 1. Go to the Jenkins server; Click **Build Now** for your project.

	

# To whom do we complain?
**apple_orchard** started as a side project of [Matthew
Kocher](https://github.com/mkocher) and [Brian
Cunnie](https://github.com/briancunnie) of Pivotal Labs in Summer 2011.
