['IMAGE_USER','IMAGE_HOST'].each do |env_variable|
  raise "ENV['#{env_variable}'] is not set!" if ENV[env_variable].nil?
end


require 'timeout'

module Util
  def image_user
    ENV['IMAGE_USER']
  end

  def image_user_at_host
    image_user + '@' + ENV['IMAGE_HOST']
  end

  def on_persistent?
    # sometimes the disks aren't mounted; mount both disks to make sure
    system("ssh #{image_user_at_host} -o ConnectTimeout=5 'sudo hdid #{$persistent_partition}; sudo hdid #{$newly_imaged_partition}; df' | grep '/Volumes/NEWLY_IMAGED'")
  end

  def reboot_to(volume)
    puts("rebooting to #{volume}")
    system("ssh #{image_user_at_host} 'sudo hdiutil attach /dev/disk0'")
    puts("Blessing #{volume}")
    system("ssh #{image_user_at_host} 'sudo bless --mount #{volume} --setboot'")
    puts("shutting down")
    system("ssh #{image_user_at_host} 'sudo shutdown -r now'")
  end

  def disappear_reappear
    # wait for machine to disappear
    Timeout::timeout(120) do
      if system("ssh #{image_user_at_host} -o ConnectTimeout=5 'true'")
        sleep 1
      end
    end

    puts "machine down"

    # wait for machine to reappear
    Timeout::timeout(120) do
      until system("ssh #{image_user_at_host} -o ConnectTimeout=5 'true'")
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

