#!/usr/bin/env ruby
#
system("ssh ci@whatscooking 'sudo shutdown -r now; exit'")
sleep 100
system("ssh ci@whatscooking 'curl https://raw.github.com/gist/6e7b9ed566721b738dac/c3ddbebb9ece1ac634718904428f50e9e4e52477/ci_build.sh > run.sh && chmod a+x run.sh'")
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
system("ssh ci@whatscooking './run.sh'");
