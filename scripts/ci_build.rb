#!/usr/bin/env ruby
#
# Meant to run on the Jenkins host
#
# Typical invocation:
#
=begin
    ./ci_build.rb \
     --ci_user_at_host ci@pivotal-workstation-ci \
     --vmware_user_at_host deploy@deploystudio \
     --vmware_cmd "/Applications/VMware\\ Fusion.app/Contents/Library/vmrun" \
     --vmware_vmx "/Volumes/SSD/Virtual\\ Machines.localized/pivotal-workstation-ci.vmwarevm/pivotal-workstation-ci.vmx"
=end

require 'optparse'

ci_user_at_host=""
vmware_user_at_host=""
vmware_cmd=""
vmware_vmx=""

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: ci_build.rb options"
  opts.on("--ci_user_at_host CI_USER_AT_HOST", "ci_user@host") do |opt|
    ci_user_at_host = opt
  end
  opts.on("--vmware_user_at_host VMWARE_USER_AT_HOST", "vmware_user@host") do |opt|
    vmware_user_at_host = opt
  end
  opts.on("--vmware_cmd CMD", "pathname to vmrun") do |opt|
    vmware_cmd = opt
  end
  opts.on("--vmware_vmx PATH", "Pathname to vmx file") do |opt|
    vmware_vmx = opt
  end
end

optparse.parse!
mandatory = [ci_user_at_host, vmware_user_at_host, vmware_cmd, vmware_vmx]
mandatory.each do |mandate|
  if mandate == ""
    puts optparse
    exit 1
  end
end

puts "stopping CI guest"
system("ssh #{vmware_user_at_host} \"sudo -u ops #{vmware_cmd} start #{vmware_vmx} hard\"")
puts "reverting CI guest to mostly_pristine snapshot"
system("ssh #{vmware_user_at_host} \"sudo -u ops #{vmware_cmd} revertToSnapshot #{vmware_vmx} mostly_pristine\"") || exit(1)
puts "starting CI guest"
system("ssh #{vmware_user_at_host} \"sudo -u ops #{vmware_cmd} start #{vmware_vmx}\"") || exit(1)

sleep 120
system("scp assets/{ci_build.sh,soloistrc} #{ci_user_at_host}:")
# FIXME: the following is pivotal-internal; need ssh-key to clone private repo
system("scp ~/.ssh/id_github_lion/ #{ci_user_at_host}:.ssh/id_rsa")
# bit-shift to increase randomness (worried polling on the minute would make modules always fail or always succeed)
now = Time.new.to_i << 2
if now % 3 != 0
  # copy the cache from chestnut to the target
  # to populate the cache on chestnut, run the following after a *successful* run
  # rsync -acvH --delete #{ci_user_at_host}:/var/chef/cache/ /var/chef/cache/
  # rsync -acvH --delete #{ci_user_at_host}:/Users/ci/Library/Caches/Homebrew/ ~/Library/Caches/Homebrew/
  system("ssh #{ci_user_at_host} 'sudo mkdir -p /var/chef/cache; sudo chown ci:admin /var/chef/cache'")
  system("rsync -aH --stats /var/chef/cache/ #{ci_user_at_host}:/var/chef/cache/")
  system("rsync -aH --stats ~/Library/Caches/Homebrew #{ci_user_at_host}:Library/Caches/")
end
# need to 'exec' instead of 'system' in order to exit with the exit_status of run.sh;
# otherwise Jenkins thinks I've always succeeded.
exec("ssh #{ci_user_at_host} './ci_build.sh'");
