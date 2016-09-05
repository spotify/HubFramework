require 'timeout'

module Waiter

  # Wait for the condition enforced by the supplied block. Will raise an
  # error if longer than timeout seconds have passed. Will wait for
  # inter_sleep seconds in between.
  def self.wait(timeout, opts={})
    status = nil
    interval = opts[:interval] || 1
    Timeout::timeout(timeout) do
      loop do
        status = yield
        break if status
        sleep(interval)
      end
      status
    end
  end

end
