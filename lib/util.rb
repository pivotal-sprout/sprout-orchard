['IMAGE_DIR','IMAGER_USER','IMAGER_HOST','DISK_PARTITION','PRISTINE_SOURCE'].each do |env_variable|
  raise "ENV['#{env_variable}'] is not set!" if ENV[env_variable].nil?
end

# export IMAGE_DIR=/Volumes/PivotLand/DeployStudio/Masters/HFS
# export IMAGER_USER=pivotal
# export IMAGER_HOST=bacon
# export DISK_PARTITION=/dev/disk0s2
# export PRISTINE_SOURCE=/Volumes/DeployStudio/Masters/HFS
# export DEPLOYSTUDIO_SSH_KEYFILE=/Users/pivotal/.ssh/id_union_deploy
# export DEPLOYSTUDIO_DESTDIR=/Volumes/PivotLand/DeployStudio/Masters/HFS
# export DEPLOYSTUDIO_USER_HOST=deploy@union

require 'timeout'

module Util
  def on_persistent?
    # sometimes the disks aren't mounted; mount both disks to make sure
    system("ssh pivotal@bacon.flood.pivotallabs.com -o ConnectTimeout=5 'sudo hdid /dev/disk0s2; sudo hdid /dev/disk0s3; df' | egrep '/Volumes/NEWLY_IMAGED|/Volumes/bacon'")
  end

  def reboot_to(volume)
    puts("rebooting to #{volume}")
    system("ssh pivotal@bacon.flood.pivotallabs.com 'sudo hdiutil attach /dev/disk0'")
    puts("Blessing #{volume}")
    system("ssh pivotal@bacon.flood.pivotallabs.com 'sudo bless --mount #{volume} --setboot'")
    puts("shutting down")
    system("ssh pivotal@bacon.flood.pivotallabs.com 'sudo shutdown -r now'")
  end

  def disappear_reappear
    # wait for machine to disappear
    Timeout::timeout(120) do
      if system("ssh pivotal@bacon.flood.pivotallabs.com -o ConnectTimeout=5 'true'")
        sleep 1
      end
    end

    puts "machine down"

    # wait for machine to reappear
    Timeout::timeout(120) do
      until system("ssh pivotal@bacon.flood.pivotallabs.com -o ConnectTimeout=5 'true'")
        sleep 1
      end
    end

  end

  def system!(cmd)
    if ! system(cmd)
      raise "#{cmd}: #{$?.exitstatus}"
    end
  end
end

