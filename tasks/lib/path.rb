module PATH
  def self.all
    return ENV['PATH'].split(':')
  end

  def self.prepend(dir)
    ENV['PATH'] = "#{dir}:#{ENV['PATH']}" if dir
    dir
  end

  def self.append(dir)
    ENV['PATH'] = "#{ENV['PATH']}:#{dir}" if dir
    dir
  end
end
