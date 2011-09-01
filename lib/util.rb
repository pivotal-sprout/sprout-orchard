require 'timeout'

module Util
  def on_persistent?
    # sometimes the disks aren't mounted; mount both disks to make sure
    system("ssh pivotal@bacon.flood.pivotallabs.com -o ConnectTimeout=5 'sudo hdid /dev/disk0s2; sudo hdid /dev/disk0s3; df' | grep /Volumes/bacon")
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

