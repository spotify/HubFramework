source 'https://rubygems.org'

gem 'danger', '~> 4.0'
gem 'danger-junit'
gem 'danger-xcode_summary'
gem 'fastlane', '~> 2.3'
gem 'jazzy', '~> 0.7.2'
gem 'xcpretty-json-formatter'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
