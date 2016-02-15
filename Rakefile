# support for older versions of ruby
Encoding.default_external = Encoding::UTF_8
require 'rubygems' if RUBY_VERSION < '1.9'

# allow requiring of .rb files in 'tasks/lib' and some common libraries
$LOAD_PATH.unshift File.expand_path('tasks/lib', File.dirname(__FILE__))

# load all rake tasks
Dir.glob('tasks/*.rake').each { |r| import r }

# default task
desc 'Alias for ci'
task :default => ['ci:run']
