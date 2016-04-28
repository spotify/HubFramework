# make sure environment is UTF-8 (CI sometimes thinks it's ASCII)
ENV['LANG'] = 'en_US.UTF-8'
ENV['LANGUAGE'] = 'en_US.UTF-8'
ENV['LC_ALL'] = 'en_US.UTF-8'
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# allow requiring of .rb files in 'tasks/lib' and some common libraries
$LOAD_PATH.unshift File.expand_path('tasks/lib', File.dirname(__FILE__))

# load all rake tasks
Dir.glob('tasks/*.rake').each { |r| import r }

# default task
desc 'Alias for ci'
task :default => ['ci:run']
