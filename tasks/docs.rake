require 'rake'
#
# Rake task for generating API documentation.
#
# Also see the associated Jazzy configurations file.
#

config_default = '.jazzy.yml'
sdk = 'iphonesimulator'

namespace :docs do

	desc "Install dependencies"
	task :deps do
		system('bundle install') or abort('bundle install failed, make sure you have installed bundler (`[sudo] gem install bundler`)')
	end

	desc "Generate documentation"
	task :generate, [:config] => [:deps] do |t, args|
		args.with_defaults(:config => config_default)
		execute_jazzy('--config', args[:config])
	end

	def execute_jazzy(*args)
		system('bundle', 'exec', 'jazzy', *args)
	end

	def path_for_sdk(sdk)
		system('xcrun', '--show-sdk-path', '--sdk', sdk)
	end
	
end

desc "Generate documentation"
task :docs => 'docs:generate'
