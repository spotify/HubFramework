source 'https://rubygems.org'

gem 'danger', '~> 3.5'
gem 'danger-junit'
gem 'fastlane', '~> 1.106'
gem 'jazzy', '~> 0.7.2'
gem 'xcpretty-json-formatter'

# Pin activesupport to the v4 since v5 requires a higher Ruby version than macOS ships with.
gem 'activesupport', '~> 4.0'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
