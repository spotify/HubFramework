require 'fileutils'
require 'rake'
#
# Rake task for generating API documentation.
#
# Also see the associated Jazzy configurations file.
#

config_default = '.jazzy.yml'

namespace :docs do

    #
    # Misc tasks

    desc "Install dependencies"
    task :deps do
        system('bundle', 'install', '--quiet') or abort('bundle install failed, make sure you have installed bundler (`[sudo] gem install bundler`)')
        puts "📖  ✅   Dependencies installed successfully."
    end

    #
    # Generating documentation

    desc "Generate the documentation"
    task :generate, [:config] => [:deps] do |t, args|
        args.with_defaults(:config => config_default)
        config_path = args[:config]

        execute_jazzy('--config', config_path) or abort("📖  ❗️  Failed to generate documentation, aborting.")

        config = YAML.load_file(config_path)
        copy_extra_resources(config)

        puts "📖  ✅   Generated successfully."
    end

    #
    # Helper functions

    # Run jazzy with the given arguments
    def execute_jazzy(*args)
        system('bundle', 'exec', 'jazzy', *args)
    end

    # Copy all extra resources
    def copy_extra_resources(config)
        html_resources_path = config["output"]
        _copy_extra_resources(html_resources_path)

        docset_resources_path = docset_resources_path(config)
        if docset_resources_path.length > 0
            _copy_extra_resources(docset_resources_path)
        end
    end

    # Private: Copies all the extra resources to the given `to_path`
    def _copy_extra_resources(to_path)
        FileUtils.cp('readme-banner.jpg', to_path)
        FileUtils.cp_r('docs/resources', to_path)
    end

    # Returns the location where DocSets are placed
    def docsets_path(config)
        return File.join(config["output"], "docsets")
    end

    # Returns the name (exluding ) of the DocSet
    def docset_name(config)
        return config["module"]
    end

    # Returns the full name (including extension) of the DocSet
    def full_docset_name(config)
        return docset_name(config) + ".docset"
    end

    # Returns the path to the DocSet
    def docset_path(config)
        full_docset_name = full_docset_name(config)
        return File.join(docsets_path(config), full_docset_name)
    end

    # Returns the path to the DocSet’s resources directory
    def docset_resources_path(config)
        return File.join(docset_path(config), "Contents", "Resources", "Documents")
    end

end

desc "Generate documentation"
task :docs => 'docs:generate'
