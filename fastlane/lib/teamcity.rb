require 'stringio'

# See TeamCity Docs for more information.
# https://confluence.jetbrains.com/display/TCD9/Build+Script+Interaction+with+TeamCity

module TeamCity

  #
  # Only returns if TeamCity is running.
  #
  def self.tc?
    return !!ENV['TEAMCITY_VERSION']
  end

  #
  # Print a TeamCity build log message.
  #
  def self.message(text)
    message_internal(text, 'NORMAL')
  end

  #
  # Print a TeamCity build log warning message.
  #
  def self.warning(text)
    message_internal(text, 'WARNING')
  end

  #
  # Print a TeamCity build log error message. This MAY fail the build depending
  # on the configuration's failure conditions.
  #
  def self.error(text, details=nil)
    message_internal(text, 'ERROR', details)
  end

  #
  # An internal helper for the "message" service message.
  #
  def self.message_internal(text, status=nil, error_details=nil)
    return unless text
    service_message 'message',
      :text => text,
      :errorDetails => error_details,
      :status => status
  end

  #
  # Set a progress message for long-running tasks. These messages will be
  # shown on the projects dashboard for the corresponding build.
  #
  def self.progress(msg)
    msg ||= '<progress>'
    if block_given?
      service_message_string('progressStart', msg)
      begin
        yield
      ensure
        service_message_string('progressFinish', msg)
      end
    else
      service_message_string('progressMessage', msg)
    end
  end

  #
  # Create a section that will be rendered as a collapsible block in the
  # TeamCity build log.
  #
  def self.block(name)
    return unless block_given?
    name ||= '<block>'
    service_message 'blockOpened', :name => name
    begin
      yield
    ensure
      service_message 'blockClosed', :name => name
    end
  end

  #
  # Print a numeric build statistic. Value accepts signed integers up to 13
  # digits OR a float with up to 6 decimal places.
  #
  def self.stat(key, value)
    service_message 'buildStatisticValue',
      :key => key,
      :value => value
  end

  #
  # Fail a build directly from the build script. Identity is a unique code for
  # this particular error. It will be generated from the description if omitted.
  #
  def self.problem(desc, identity=nil)
    service_message 'buildProblem',
      :description => desc,
      :identity => identity
  end

  #
  # Set the success text for the current build.
  #
  def self.success(msg)
    service_message 'buildStatus',
      :status => 'SUCCESS',
      :text => msg
  end

  #
  # Set the build number for the current build.
  #
  def self.build_number(value)
    service_message_string('buildNumber', value)
  end

  #
  # XML reporting helper. See TC docs for valid type IDs.
  #
  def self.import_data(type_id, path, extra={})
    return unless type_id && path
    service_message 'importData', {
      :type => type_id,
      :path => path
    }.merge(extra)
  end

  #
  # Publish an artifact now. Uploads happen in the background so make sure the
  # will exist until the end of the build. The path must be relative to the
  # checkout directory (repo root) and must adhere to the same syntax used when
  # configuring the build:
  #
  # http://bit.ly/1TPWTYD#ConfiguringGeneralSettings-artifactPaths
  #
  def self.publish_artifacts(path)
    service_message_string('publishArtifacts', path)
  end

  #
  # Escape a string (or the stringification of another value) for use in
  # TeamCity messages.
  #
  def self.escape(value)
    string = "#{value}"
    string.gsub!('|', '||')
    string.gsub!("'", "|'")
    string.gsub!("\n", '|n')
    string.gsub!("\r", '|r')
    string.gsub!('[', '|[')
    string.gsub!(']', '|]')
    return string
  end

  #
  # Print a service message with a name and property list.
  #
  def self.service_message(message_name, properties={})
    return unless tc?
    buffer = StringIO.new
    unless properties.empty?
      properties.each do |key, value|
        next unless key && value
        buffer.write " #{key}='#{escape(value)}'"
      end
    end
    $stdout.puts "##teamcity[#{message_name}#{buffer.string}]"
  end

  #
  # Some service messages don't have a property list, but rather just a string.
  #
  def self.service_message_string(message_name, string)
    return unless tc? && message_name
    $stdout.puts "##teamcity[#{message_name} '#{escape(string)}']"
  end
end
