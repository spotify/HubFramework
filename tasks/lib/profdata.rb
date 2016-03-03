require 'json'

# parse a profdata file into a consumable format
class Profdata
  VERBOSE_LOG = (ENV['PROFDATA_VERBOSE'].to_i == 1)

  class FileInfo
    BRACE_ONLY_REGEX = /^\s*[\}\{]\s*$/
    WHITESPACE_ONLY_REGEX = /^\s*$/
    COMBINED_REGEX = Regexp.union([BRACE_ONLY_REGEX, WHITESPACE_ONLY_REGEX])

    attr_accessor :path
    attr_reader :line_count, :breakdown

    def initialize(path)
      @path = path
      @line_count = `wc -l "#{path}"`.strip.to_i
      @breakdown = {}
    end

    def mark(line, hits)
      existing = @breakdown[line] || 0
      @breakdown[line] = existing + hits
    end

    def make_adjustments!
      cnt = 0
      File.open(@path, 'r') do |fd|
        idx = 0
        excluding = false
        while line = fd.gets
          idx += 1
          exclude_line = line =~ /LCOV_EXCL_LINE/
          excluding = true if line =~ /LCOV_EXCL_START/

          if excluding || exclude_line || line =~ COMBINED_REGEX
            cnt += 1 if @breakdown.delete(idx)
          end

          excluding = false if line =~ /LCOV_EXCL_STOP/
        end
      end
      cnt
    end

    def to_codecov_array
      (0..@line_count).map {|n| @breakdown[n]}
    end

    def stats
      total = @breakdown.length
      covered = @breakdown.reduce(0) { |memo, (key, val)| memo += (val > 0 ? 1 : 0) }
      [total, covered]
    end
  end

  attr_reader :data

  def initialize
    @data = {}
  end

  def self.from_derived_data(dd)
    pd = Profdata.new

    for cov_path in Dir[File.join(dd, '**/Coverage.profdata')]
      verbose_log cov_path
      dir = File.dirname(cov_path)
      for bin_root in Dir["#{dir}/**/*.{app,framework,xctest}"]
        bin = File.basename(bin_root, File.extname(bin_root))
        pd.process(cov_path, "#{bin_root}/#{bin}")
      end
    end

    pd.normalize!
    pd
  end

  def process(profdata, binary)
    current = nil
    processed = 0

    # this command has some heavy output
    cmd = Shellwords.shelljoin([
      'xcrun', 'llvm-cov', 'show',
      '--instr-profile', profdata, binary
    ])

    verbose_log("Processing llvm-cov output...")
    IO.popen("#{cmd} 2>/dev/null") do |raw_line|
      while line = raw_line.gets
        # chop off prefix for inline invocations
        line.chomp!
        line = line[3..-1] if line.start_with?('  |')

        # skip lines known to be ones we don't care about
        next if line.length == 0               # ignore empty lines
        next if line.start_with?('warning:')   # ignore warnings
        next if line.start_with? '       |'    # ignore lines with no executable code
        next if line.start_with? '  ----'      # ignore separator lines
        next if line =~ /^ [^\s\d]/            # ignore lines without sufficient whitespace or numbers

        if (m = line.match(/^(\/.*):/))
          # parse filename
          path = File.expand_path(m[1])
          current = @data[path]
          if !current
            current = FileInfo.new(path)
            processed += 1
            @data[path] = current
          end
        elsif (m = line.match(/^\s+([\d\.]+[a-zA-Z]?)\|\s*(\d+)\|/))
          # parse lines with execution count
          # this output formats numbers weirdly and a lot of precision gets lost.
          # until we figure out another way, we'll just max out at 1000
          line_no = m[2].to_i
          hits = (m[1] =~ /^\d+$/) ? m[1].to_i : 1000
          current.mark(line_no, hits)
        else
          # don't know how to parse this line =(
          raise("profdata parser: bad line: \n" + line)
        end
      end
    end
    verbose_log("Data from #{processed} sources processed.")
    processed
  end

  def normalize!(root=Dir.pwd)
    # normalize paths:
    # any files not relative to the specified root will be omitted.
    # file paths will be converted to be relative to the root.
    # this will also sort the hash by path (hashes are insertion-
    # sorted as of ruby 1.9)
    verbose_log("Normalizing paths...")
    root = "#{root}/" unless root.end_with?('/')
    root_len = root.length
    stripped = 0
    @data.keys.sort.each do |path|
      info = @data.delete(path)
      unless path.start_with?(root)
        stripped += 1
        next
      end
      path = path[(root_len)..-1]
      @data[path] = info
      info.path = path
    end
    verbose_log("Removed #{stripped} source(s) during normalization.")

    # perform coverage adjustments:
    # any lines containing a single curly brace shall be omitted.
    verbose_log("Making adjustments...")
    adjustments = 0
    @data.each do |path, info|
      adjustments += info.make_adjustments!
    end
    verbose_log("Made #{adjustments} adjustment(s)...")
  end

  def reject_paths!
    cnt = 0
    @data.reject! do |path, _|
      val = !!yield(path)
      cnt += (val ? 1 : 0)
      val
    end
    verbose_log("Removed #{cnt} source(s) via supplied rule.")
    cnt
  end

  def stats
    self.class.collect_stats(@data.values)
  end

  def write_codecov_file(outpath)
    File.open(outpath, 'w') do |fd|
      cc = {}
      @data.each do |path, info|
        cc[path] = info.to_codecov_array
      end
      JSON.dump(cc, fd)
      outpath
    end
  end

  def self.verbose_log(msg)
    puts("#{Time.now.strftime('%H:%M:%S.%L')}  #{msg}") if VERBOSE_LOG
  end

  def verbose_log(msg)
    self.class.verbose_log(msg)
  end

  def self.collect_stats(infos)
    covered = total = 0
    infos.each do |info|
      t,c = info.stats
      covered += c
      total += t
    end
    [total, covered]
  end
end
