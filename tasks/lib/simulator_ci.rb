require 'simulator'
require 'xcode'

module Simulator

  def self.ci_device_type
    ENV['SIM_DEVICE'] || Device::IPHONE_6S
  end

  def self.ci_device_version
    ENV['SIM_OS'] || Xcode.default_ios_sdk
  end

  def self.ci_device
    # returns a singleton object. will create if nonexistent.
    # will return if already exists.
    Device.prepare_custom_ios!(ci_device_type, ci_device_version)
  end

end
