source 'https://rubygems.org'

gem 'danger', '~> 5.5'
gem 'danger-junit'
gem 'danger-xcode_summary'
gem 'fastlane', '~> 2.66'
gem 'jazzy', '~> 0.9'
gem 'xcpretty-json-formatter'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
