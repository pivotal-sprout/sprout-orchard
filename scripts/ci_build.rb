#!/usr/bin/env ruby
#
# Meant to run on the Jenkins host
#
ci_host="pivotal-workstation-ci"
ci_user="ci"
vmware_user="pivotal"
vmware_host="deploystudio"
vmware_user="pivotal"
vmware_cmd="/Applications/VMware\ Fusion.app/Contents/Library/vmrun"
vmware_vmx="/Volumes/SSD/Virtual\ Machines.localized/pivotal-workstation-ci.vmwarevm/pivotal-workstation-ci.vmx"

system("ssh #{vmware_user}@#{vmware_host} \"#{vmware_cmd} stop #{vmware_vmx}\"")
exit
sleep 120
system("scp assets/{ci_build.sh,soloistrc} ci@whatscooking:")
# bit-shift to increase randomness (worried polling on the minute would make modules always fail or always succeed)
now = Time.new.to_i << 2
if now % 3 != 0
  # copy the cache from lilac to the target
  # to populate the cache on lilac, run the following after a *successful* run
  # rsync -acvH --delete ci@whatscooking:/var/chef/cache/ /var/chef/cache/
  # rsync -acvH --delete ci@whatscooking:/Users/ci/Library/Caches/Homebrew/ ~/Library/Caches/Homebrew/
  system("ssh ci@whatscooking 'sudo mkdir -p /var/chef/cache; sudo chown ci:admin /var/chef/cache'")
  system("rsync -aH --stats /var/chef/cache/ ci@whatscooking:/var/chef/cache/")
  system("rsync -aH --stats ~/Library/Caches/Homebrew ci@whatscooking:Library/Caches/")
end
# need to 'exec' instead of 'system' in order to exit with the exit_status of run.sh;
# otherwise Jenkins thinks I've always succeeded.
exec("ssh ci@whatscooking './ci_build.sh'");
