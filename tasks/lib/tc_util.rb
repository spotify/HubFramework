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

  def TCUtil.stat(key, value)
    message "buildStatisticValue key='#{key}' value='#{value}'"
  end

  def TCUtil.info
    branch = ENV['GIT_BRANCH'] || ENV['PROJECT_BRANCH'] || `git rev-parse --abbrev-ref HEAD`.strip
    branch = branch.gsub(/^refs\/heads\//, '')

    return {
      :branch => branch,
      :commit => ENV['BUILD_VCS_NUMBER'] || `git rev-parse HEAD`.strip,
      :pr => branch.scan(/^refs\/pull\/(\d+)/).flatten.first,
      :build_id => ENV['TEAMCITY_BUILD_ID']
    }
  end

end
