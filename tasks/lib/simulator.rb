# need rubygems for Gem::Version
require 'rubygems'
require 'json'
require 'set'
require 'shellwords'
require 'xcode'
require 'waiter'
require 'launchctl'

module Simulator

  # Reset the core simulator service. You should only need to call this
  # once, before you do anything else with simulators. This is necessary
  # as a simulator service instance that doesn't correspond to the currently
  # selected Xcode may be running.
  def self.kill_all!
    # make sure Xcode is bootstrapped (use proper simctl instance)
    Xcode.bootstrap!

    # kill Simulator.app
    kill!

    # stop launchd_sim services
    Launchctl.stop_services_matching!(/SimDevice/)

    # stop simulator service
    Launchctl.stop_services_matching!('com.apple.CoreSimulator.CoreSimulatorService')
  end

  # Kill all running instances of the simulator application.
  # @return true if an instance was killed.
  def self.kill!
    !!system('pkill', '-9', '-x', 'Simulator')
  end

  # Kill all simulators when this process exits.
  def self.kill_at_exit!
    @@kill_at_exit = begin
      at_exit do
        Simulator.kill!
      end
      true
    end
  end

  # The location of the simulator app for the current xcode.
  def self.location
    "#{Xcode.developer_dir}/Applications/Simulator.app"
  end

  # Open the simulator
  def self.open(udid=nil, new_window=false)
    cmd = ['open']
    cmd.push('-n') if new_window
    cmd.push('-F', '-g', '-a', location)
    cmd.push('--args', '-CurrentDeviceUDID', udid) if udid
    system(*cmd)
  end

  # Get parsed JSON output from the given simulator list command.
  # @return [Hash, Array, nil] The parsed JSON.
  def self.simctl_json(type)
    Xcode.bootstrap!
    JSON.parse(`xcrun simctl list #{type} -j`)[type]
  end

  # Run the given command under simctl
  def self.simctl_run(*args)
    Xcode.bootstrap!
    opts = args.last.is_a?(Hash) ? args.pop : {}
    cmd = Shellwords.shelljoin(['xcrun', 'simctl', *args])
    cmd = "#{cmd} 2>/dev/null" if opts[:suppress_stderr]
    system(cmd)
  end

  # 
  # A class representing a device that can be represented in the iOS simulator.
  #
  class Device
    attr_reader :name, :udid, :type, :status, :runtime, :available
    alias_method :available?, :available

    # Device name constants (for convenience)
    IPHONE_4S      = 'iPhone 4s'
    IPHONE_5       = 'iPhone 5'
    IPHONE_5S      = 'iPhone 5s'
    IPHONE_6       = 'iPhone 6'
    IPHONE_6_PLUS  = 'iPhone 6 Plus'
    IPHONE_6S      = 'iPhone 6s'
    IPHONE_6S_PLUS = 'iPhone 6s Plus'
    IPHONE_SE      = 'iPhone SE' # xcode 8
    IPAD_2         = 'iPad 2'
    IPAD_RETINA    = 'iPad Retina'
    IPAD_AIR       = 'iPad Air'
    IPAD_AIR_2     = 'iPad Air 2'
    IPAD_PRO_9_7   = 'iPad Pro (9.7-inch)' # xcode 8
    IPAD_PRO_12_9  = 'iPad Pro (12.9-inch)' # xcode 8
    IPAD_PRO       = 'iPad Pro' # xcode 7
    APPLE_TV_1080P = 'Apple TV 1080p'
    APPLE_WATCH_38 = 'Apple Watch - 38mm'
    APPLE_WATCH_42 = 'Apple Watch - 42mm'

    # Class vars
    @@device_lookup = {}
    @@lock = Mutex.new

    # Refresh the device master list.
    # @return [Array<Device>] The list of ALL devices.
    def self.synchronize!
      @@lock.synchronize do
        all_udids = []

        Simulator.simctl_json('devices').map do |rt_name, devices|
          rt = Runtime.find_by_name(rt_name)
          devices.each do |json|
            udid = json['udid']
            all_udids << udid
            dev = @@device_lookup[udid]
            if dev
              dev.update(json)
            else
              dev = self.new(json, rt)
              @@device_lookup[udid] = dev
            end
          end
        end

        missing = @@device_lookup.keys - all_udids
        missing.each do |udid|
          dev = @@device_lookup.delete(udid)
          dev.set_gone!
        end

        @@device_lookup
      end
    end

    # Get a list of all simulator devices.
    # @return [Array<Device>] An array of available simulator devices.
    def self.all(avail_only=true)
      list = synchronize!.values
      return avail_only ? list.select{|d| d.available?} : list
    end

    # Find a device exactly matching the given name.
    # @param [String] name The name of the device
    # @return [Device, nil] The device matching the given name.
    def self.find_by_name(name)
      all.find{|d| d.name == name}
    end

    # Find a device exactly matching the given UDID.
    # @param [String] udid The UDID of the device
    # @return [Device, nil] The device matching the given UDID.
    def self.find_by_udid(udid)
      all.find{|d| d.udid == udid}
    end

    # Prepare a custom iOS device. If the os version is null,
    #  the most recent available runtime will be used.
    # @param [String] device_name "iPhone 6"
    # @param [String] version  "9.2" or nil
    # @return [Device]
    def self.prepare_custom_ios!(device_name, version=nil)
      runtime = nil
      if version
        rt = "iOS #{version}"
        runtime = Runtime.find_by_name(rt)
        raise "Could not find runtime \"#{rt}\"" unless runtime
      else
        runtime = Runtime.latest_by_type(:ios)
        raise "Could not find latest iOS runtime." unless runtime
      end
      
      type = DeviceType.find_by_name(device_name)
      raise "Bad device name: \"#{device_name}\"" unless type
      part = type.identifier.split('.').last

      unique_name = "spt:#{part}:#{runtime.version}"
      find_by_name(unique_name) || create!(unique_name, type.identifier, runtime.identifier)
    end

    # Create a new device.
    # @param [String] name        The name for this device.
    # @param [String] type_id     The device type identifier.
    # @param [String] runtime_id  The runtime identifier.
    # @return [Device] a new Device instance.
    def self.create!(name, type_id, runtime_id)
      puts "Creating \"#{name}\" (#{runtime_id})"
      if !Simulator.simctl_run('create', name, type_id, runtime_id)
        raise Exception.new("Failed to create device #{name}")
      end
      dev = Waiter.wait(10, :interval => 0.5) do
        Device.find_by_name(name)
      end
      raise Exception.new("Failed to create device #{name}") unless dev
      return dev
    end

    # Is this device a 32-bit device?
    def architecture
      self.type ? self.type.architecture : nil
    end

    # Erase all content and applications from this device.
    # @return self
    def erase!
      Simulator.simctl_run('erase', udid) or raise "Couldn't erase #{udid}"
      self
    end

    # Delete this device from simctl. Don't use the object after this point.
    #   as its behavior is considered undefined.
    # @return self
    def delete!
      if status != :gone
        Simulator.simctl_run('delete', udid) or raise "Couldn't delete #{udid}"
        wait_for_status(:gone)
      end
      self
    end

    # Bring this device into a shutdown state.
    # @return self
    def shutdown!
      if status != :shutdown
        Simulator.simctl_run('shutdown', udid, :suppress_stderr=>true)
        wait_for_status!(:shutdown)
      end
      self
    end

    # Bring this device into a booted state.
    # @return self
    def boot!
      if status != :booted
        Simulator.simctl_run('boot', udid, :suppress_stderr=>true)
        wait_for_status!(:booted)
      end
      self
    end

    # Kill other sims and launch the given device.
    # @return self
    def launch_fresh!(wait=false)
      Simulator::kill!
      shutdown!
      erase!
      Simulator::open(udid, false)
      wait_for_status!(:booted) if wait
      self
    end

    # Launch a new simulator instance even if one is already open.
    # @return self
    def launch_new!
      raise 'Should be shutdown' if status != :shutdown
      Simulator::open(udid, true)
      wait_for_status!(:booted)
      self
    end

    # Get the destination for this simulator.
    def destination
      udid ? "platform=iOS Simulator,id=#{udid}" : nil
    end

    # Wait for the simulator to be in the given status.
    def wait_for_status!(st, timeout=60)
      return true if status == st
      Waiter.wait(timeout, :interval => 0.5) do
        self.class.synchronize!
        self.status == st
      end
    end

    def initialize(json, runtime)
      @runtime = runtime
      update(json)
    end

    def update(json)
      @name = (json['name'] rescue nil)
      @udid = (json['udid'] rescue nil)
      @status = (json['state'].downcase.to_sym rescue :unknown)
      @available = ((json['availability'] == '(available)') rescue false)
      @type = coerce_type(@name)
      self
    end

    def coerce_type(name)
      return nil unless name
      m = name.match(/^spt:(.*?):/)
      name = m[1] if m
      DeviceType.find_by_name(name)
    end

    def set_gone!
      @status = :gone
    end
  end

  #
  # A class representing a simulator runtime.
  # ex. com.apple.CoreSimulator.SimRuntime.iOS-9-2
  #
  class Runtime
    attr_reader :name, :type, :version, :build, :identifier, :available
    alias_method :available?, :available

    # The list of available runtimes.
    # @return [Array<Runtime>] An array of runtime objects.
    def self.all
      @@runtimes = Simulator.simctl_json('runtimes').map {|json| self.new(json)}.select{|r| r.available?}
    end

    # Get the runtime for the given name (ex. "iOS 9.2")
    # @return [Runtime, nil] The matching runtime.
    def self.find_by_name(name)
      @@rtlookup ||= self.all.reduce({}) do |acc, rt|
        acc[rt.name] = rt
        acc
      end
      return @@rtlookup[name]
    end

    # The most recent runtime of the given type
    #   ex. latest_by_type(:ios) => <Runtime: com.apple.CoreSimulator.SimRuntime.iOS-9-2>
    # @return [Runtime, nil] The matching runtime.
    def self.latest_by_type(type)
      all.select{|r| r.type == type}.max_by(&:version)
    end

    # Initialize with JSON from simctl
    # @return [Runtime]
    def initialize(json)
      @name = json['name']
      @type = @name.split(/\s+/).first.downcase.to_sym
      @version = Gem::Version.new(json['version'])
      @build = json['buildversion']
      @identifier = json['identifier']
      @available = (json['availability'] == '(available)')
    end
  end

  #
  # A class representing a device type.
  #
  class DeviceType
    attr_reader :name, :identifier, :architecture

    def self.all
      @@all ||= Simulator.simctl_json('devicetypes').map{|json| self.new(json) }
    end

    def self.find_by_name(name)
      @@namelookup ||= build_name_lookup
      return @@namelookup[normalize_for_lookup(name)]
    end

    def self.is_32_bit?(name)
      @@lookup32 ||= Set.new([Device::IPHONE_4S, Device::IPHONE_5, Device::IPAD_2, Device::IPAD_RETINA])
      return @@lookup32.include?(name)
    end

    def initialize(json)
      @name = json['name']
      @identifier = json['identifier']
      @is_32_bit = self.class.is_32_bit?(name)
      @architecture = @is_32_bit ? 'i386' : 'x86_64'
    end

    def is_32_bit?
      @is_32_bit
    end

    private

    def self.build_name_lookup
      lookup = {}
      for obj in self.all
        ident = obj.identifier
        part = ident.split('.').last

        lookup[normalize_for_lookup(obj.name)] = obj
        lookup[normalize_for_lookup(ident)] = obj
        lookup[normalize_for_lookup(part)] = obj
      end
      lookup
    end

    def self.normalize_for_lookup(value)
      value ? value.downcase.gsub(/[^a-z0-9]+/, '') : nil
    end
  end

end
