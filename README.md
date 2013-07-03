Sprout Orchard is a set of scripts (bash & ruby) which run the 
[Chef](http://www.opscode.com/chef/)
recipes in [Pivotal Workstation](https://github.com/pivotal/pivotal_workstation)
in order to create OS X disk images which are deployed via 
[DeployStudio](http://www.deploystudio.com/Home.html).

## Why?

Sprout Orchard delivers a disk image which we can use to quickly (~20 minutes)
bring a freshly-unboxed OS X machine to a useful state.

In our case, we use it for our developer workstations.  Our developers
use a variety of tools (IDEs such as RubyMine, editors such as vim and TextMate,
databases such as MySQL and PostgrSQL, applications such as Chrome and Skype).
When we give a developer a new machine, it is pre-loaded with those items.

Our process of building a developer workstation is encapsulated in a series
of Chef recipes (i.e. Pivotal Workstation).  Sprout Orchard pre-bakes those 
recipes in a disk image.  Installing the disk image is faster than running
the Chef recipes on each new workstation. Also, having a disk image spares the 
developer from problems such as inaccessible download servers, stale URLs, etc.

The process is fairly automated.  A typical workflow is as follows:

* A developer updates the TextMate recipe and pushes to Pivotal's pivotal_workstation repo on github
* A Sprout Orchard Jenkins server detects that there has been an update to the repo and begins a build
* At the end of the build (assuming success), the resulting disk image, with the new TextMate, is copied to the DeployStudio server 

## How do I set it up?

If you're interested in setting it up yourself, please refer to the [wiki](https://github.com/pivotal-sprout/sprout-orchard/wiki/)

## What will I need?

You'll need the following:

1.  A DeployStudio server
2.  A [Jenkins](http://jenkins-ci.org/)  server (can also be the same machine as the DeployStudio server)
3.  An OS X build machine (it can be a virtual machine running under VMWare Fusion)

## Bugs

This process doesn't capture recovery partitions 
(i.e. a newly-imaged machine won't have a recovery partition); however, this
is workable by creating a package which installs a recovery partition.
[This blogpost](http://derflounder.wordpress.com/2012/06/26/creating-an-updated-recovery-hd/)
has good information.

The build process will frequently fail, a success rate of 20% is good.
Failures can be caused by the DeployStudio share not mounted on boot by 
the OS X machine's "Persistent" personality, by stale download URLs, by offline
download servers, by flawed gem dependencies, etc....

# To whom do we complain?
**sprout-orchard** started as a side project of [Matthew
Kocher](https://github.com/mkocher) and [Brian
Cunnie](https://github.com/briancunnie) of Pivotal Labs in Summer 2011.
