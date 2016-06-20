require 'fileutils'
require 'rake'
require 'securerandom'
require 'tmpdir'
require 'yaml'

#
# Rake task for generating API documentation.
#
# Also see the associated Jazzy configurations file.
#

# The default path for the Jazzy config file
CONFIG_PATH_DEFAULT = '.jazzy.yml'

# The default branch of the repo to which we publish documentation
PUBLISH_REPO_BRANCH_DEFAULT = 'gh-pages'

namespace :docs do

    #
    # Misc tasks

    desc "Generate and publish the documentation"
    task :all => [:generate, :publish]

    desc "Install dependencies"
    task :deps do
        puts "📖  👉   Installing dependencies…"
        system('bundle', 'install', '--quiet') or abort("📖  ❗️  bundle install failed, make sure you have installed bundler (`[sudo] gem install bundler`)")
        puts "📖  ✅   Dependencies installed successfully."
    end

    #
    # Generating documentation

    desc "Generate the documentation"
    task :generate do
        puts "📖  👉   Generating documentation…"

        config_path = get_config_path()
        config = YAML.load_file(config_path)

        module_version = module_version(".", config, get_build_number())

        execute_jazzy(
            '--config', config_path,
            '--module-version', module_version
        ) or abort("📖  ❗️  Failed to generate documentation, aborting.")

        copy_extra_resources(config)
        rebuild_docset_archive(config) # We need to rebuild the DocSet archive since we’ve copied more resources into it.

        puts "📖  ✅   Generated successfully."
    end

    #
    # Publishing the documentation

    desc "Publish the documentation to gh-pages"
    task :publish do
        puts "📖  👉   Publishing documentation…"

        config = YAML.load_file(get_config_path()) or abort("📖  ❗️  Failed to read jazzy config, aborting.")
        docs_path = config["output"] 

        if not File.directory?(docs_path)
            puts "📖  ❗️  No documentation found, aborting."
            exit!(1)
        end

        repo = get_publish_repo(".")
        branch = get_publish_branch()

        tmp_dir = publish_tmp_dir_path()

        repo_name = "docs-repo"
        repo_dir = File.join(tmp_dir, repo_name)

        puts "📖  💁️   Creating temporary publishing directory at:"
        puts "📖   ️     \"#{tmp_dir}\""
        prepare_publish_dir(tmp_dir)

        git_clone_repo(repo, branch, repo_dir)
        publish_docs(tmp_dir, repo_dir, branch, docs_path, git_head_hash(repo_dir))
        cleanup_publish_dir(tmp_dir)

        puts "📖  ✅   Published successfully."
    end


    #
    # Generating documentation helper functions

    # Run jazzy with the given arguments
    def execute_jazzy(*args)
        system('bundle', 'exec', 'jazzy', *args)
    end

    # Returns the string that should be used as the module version
    def module_version(repo_dir, config, build)
        version = config["module_version"] || git_current_branch(repo_dir) || "unknown"
        
        if (not build.nil?) && build.length > 0
            return version + "-" + build
        else
            return version
        end
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
        FileUtils.cp_r('documentation/resources', to_path)
    end

    # Rebuilds the DocSet archive
    def rebuild_docset_archive(config)
        docset_path = docset_path(config)
        if not File.directory?(docset_path)
            return
        end

        docsets_path = docsets_path(config)
        docset_name = docset_name(config)

        full_archive_name = docset_name + ".tgz"
        archive_path =  File.join(docsets_path, full_archive_name)

        # Remove the existing archive
        File.file?(archive_path) and FileUtils.rm(archive_path)

        # Create a new archive in the same location
        Dir.chdir(docsets_path) do
            system(
                'tar',
                '--exclude=\'.DS_Store\'',
                '-czf',
                full_archive_name,
                full_docset_name(config)
            )
        end
    end


    #
    # Publishing helper functions

    # The path to the temp directory used for publishing
    def publish_tmp_dir_path()
        user_tmp_dir_container = ENV['DOCS_TMP_DIR_CONTAINER']
        if (not user_tmp_dir_container.nil?) && user_tmp_dir_container.length > 0
            subdir = File.join(
                user_tmp_dir_container,
                SecureRandom.uuid
            )
        else
            subdir = SecureRandom.uuid
        end

        return File.join(
            Dir.tmpdir(),
            subdir
        )
    end

    # Prepare the temporary directory used for publishing
    def prepare_publish_dir(path)
        cleanup_publish_dir(path)
        FileUtils.mkdir_p(path)
    end

    # Cleanup a publish dir at the given path
    def cleanup_publish_dir(path)
        FileUtils.rm_rf(path, secure: true)
    end

    # Remove some files, copy some other files, commit and push!
    def publish_docs(tmp_dir, repo_dir, branch, docs_dir, for_commit)
        # Remove all files in the repo, otherwise we might get lingering files that aren’t
        # generated by jazzy anymore. This won’t remove any dotfiles, which is intentional.
        FileUtils.rm_rf(Dir.glob("#{repo_dir}/*"), secure: true)

        # Copy all of the newly generated documentation files that we want to publish.
        FileUtils.cp_r("#{docs_dir}/.", repo_dir)

        # Create a nifty commit message.
        commit_msg_path = File.join(tmp_dir, 'commit_msg')
        create_commit_msg(commit_msg_path, for_commit)

        # Stage, commit and push!
        execute_git(repo_dir, 'add', '.')
        execute_git(repo_dir, 'commit', '--quiet', '-F', commit_msg_path)
        execute_git(repo_dir, 'push', '--quiet', 'origin', branch)
    end


    #
    # Dealing with git

    # Create a commit message for a given commit
    def create_commit_msg(commit_msg_path, for_commit)
        File.open(commit_msg_path, 'w') do |file|
            file.puts("Automatic documentation update\n")
            file.puts("- Generated for #{for_commit}.")
        end
    end

    # Clone a repo to the given destination
    def git_clone_repo(repo, branch, destination)
        system('git', 'clone', '--quiet', '-b', branch, repo, destination)
    end

    # Returns the URL of the origin rmeote
    def git_origin_remote_url(repo_dir)
        # Attempt to use the upstream reference if it exists, otherwise use origin.
        return (
            `git -C "#{repo_dir}" config --get remote.upstream.url` ||
            `git -C "#{repo_dir}" config --get remote.origin.url`
        ).strip
    end

    # Returns the current HEAD’s git hash
    def git_head_hash(repo_dir)
        return `git -C "#{repo_dir}" rev-parse HEAD`.strip
    end

    def git_current_branch(repo_dir)
        if repo_dir.nil?
            return nil
        end

        return `git -C "#{repo_dir}" rev-parse --abbrev-ref HEAD`.strip
    end

    # Executes the given git commands and options (*args) in the given repo_dir
    def execute_git(repo_dir, *args)
        system('git', '-C', repo_dir, *args)
    end


    #
    # DocSet information

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


    #
    # Environment configuration options

    # Returns the path to the docs generator config
    def get_config_path()
        return ENV['DOCS_CONFIG_PATH'] || CONFIG_PATH_DEFAULT
    end

    # Returns the current build number, or HEAD if not available
    def get_build_number()
        return ENV['DOCS_BUILD_NUMBER'] || "HEAD"
    end

    # Returns the URL of the repo to which we publish, or the origin URL for the repo at repo_dir.
    def get_publish_repo(repo_dir)
        return ENV['DOCS_PUBLISH_REPO_URL'] || git_origin_remote_url(repo_dir)
    end

    # Returns the branch which should be used in publish repo.
    def get_publish_branch()
        return ENV['DOCS_PUBLISH_REPO_BRANCH'] || PUBLISH_REPO_BRANCH_DEFAULT
    end

end

desc "Generate and publish the documentation"
task :docs => 'docs:generate'
