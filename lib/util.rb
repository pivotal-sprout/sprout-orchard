require 'timeout'

module Util
  def on_persistent?
    system("ssh pivotal@bacon.flood.pivotallabs.com -o ConnectTimeout=5 '[[ -d /Volumes/bacon ]]'")
  end

  def reboot_to(volume)
    puts("rebooting to #{volume}")
    system("ssh pivotal@bacon.flood.pivotallabs.com 'sudo bless --mount #{volume} --setboot'")
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

