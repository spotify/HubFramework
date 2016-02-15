require 'rake'
require 'set'
require 'shellwords'

module TCUtil

  def TCUtil.message(message)
    puts "##teamcity[#{message}]" if ENV['TEAMCITY_VERSION']
  end

  def TCUtil.block(name)
    message "blockOpened name='#{name}'"
    begin
      yield
    ensure
      message "blockClosed name='#{name}'"
    end
  end

end
