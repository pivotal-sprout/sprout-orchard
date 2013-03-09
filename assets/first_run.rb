#!/usr/bin/env ruby

module SetHostName
  def self.perform
    system '/usr/sbin/auto_set_hostname.rb' or warn 'WARNING: Set hostname failed'
  end
end

module RunSoloist
  def self.perform
    system 'gem install soloist' or raise 'Installing soloist failed!'
    system 'soloist' or raise 'First soloist run failed!'
  end
end

SetHostName.perform
RunSoloist.perform
