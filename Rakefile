# support for older versions of ruby
Encoding.default_external = Encoding::UTF_8
require 'rubygems' if RUBY_VERSION < '1.9'

# load all rake tasks
Dir.glob('tasks/*.rake').each { |r| import r }
