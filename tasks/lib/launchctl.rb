require 'waiter'

module Launchctl

  def self.stop_services_matching!(regex_or_string)
    Waiter.wait(20, :interval=>2) do
      matches = get_services_matching(regex_or_string)
      for name in matches
        puts "Stopping service #{name}"
        system('launchctl', 'remove', name)
        system('launchctl', 'stop', name)
      end
      matches.empty?
    end
  end

  def self.get_services_matching(regex_or_string)
    regex = coerce_regex(regex_or_string)
    `launchctl list | awk '{print $3}'`.strip.split("\n").select{|x| x =~ regex }
  end

  def self.coerce_regex(value)
    return value if value.is_a?(Regexp)
    return (/^#{value}$/) if value.is_a?(String)
    raise ArgumentError.new("Could not coerce into regex -- #{value}")
  end

end
