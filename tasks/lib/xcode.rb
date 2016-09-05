require 'path'

module Xcode

  def self.bootstrap!
    @@bootstrapped ||= begin
      dd = `xcode-select -p`.strip
      raise Exception.new('xcode-select failed!') unless $?.success?

      unless dd && File.directory?(dd)
        raise Exception.new("Invalid DEVELOPER_DIR: #{dd}")
      end

      ENV['DEVELOPER_DIR'] = dd

      # Set up PATH and other goodies
      toolchain_bin = "#{dd}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
      PATH.prepend("#{dd}/usr/bin")
      PATH.prepend(toolchain_bin)
      ENV['CODESIGN_ALLOCATE'] = "#{toolchain_bin}/codesign_allocate"

      true
    end
  end

  def self.developer_dir
    bootstrap!
    return ENV['DEVELOPER_DIR']
  end

  def self.default_ios_sdk
    @@default_ios_sdk ||= begin
      plist = "#{developer_dir}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/SDKSettings.plist"
      `/usr/libexec/PlistBuddy -c "Print :DefaultDeploymentTarget" "#{plist}"`.strip
    end
  end

end
