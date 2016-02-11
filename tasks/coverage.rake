require 'set'
require 'shellwords'

# Coverage handling
namespace :coverage do

    desc 'Report coverage to Codecov'
    task :report_to_codecov do
        raise '`CODECOV_URL` not set in environment' unless ENV['CODECOV_URL']
        raise '`CODECOV_TOKEN` not set in environment' unless ENV['CODECOV_TOKEN']
        raise '`GIT_BRANCH` not set in environment' unless ENV['BUILD_VCS_NUMBER']
        raise '`DERIVED_DATA_PATH` not set in environment' unless ENV['DERIVED_DATA_PATH']

        cmd = codecov_cmd(
            ENV['CODECOV_URL'],
            ENV['CODECOV_TOKEN'],
            ENV['DERIVED_DATA_PATH'],
            ENV['BUILD_VCS_NUMBER'],
            ENV['GIT_BRANCH'],
            ENV['TEAMCITY_BUILD_ID']
        )

        TCUtil.block('Report coverage to Codecov') do
            clean_cmd = cmd.gsub(ENV['CODECOV_TOKEN'], '<codecov-token>')
            puts "Executing \"#{clean_cmd}\""
            system cmd or exit!(1)
        end
    end

    desc 'Clean the project'
    task :clean do
        # Xcode likes to put files in the source root for some reason, let’s remove them.
        puts "Cleaning repository from code coverage files"
        system('rm *.gcda > /dev/null 2>&1')
        system('rm *.gcno > /dev/null 2>&1')
    end

    desc 'Run all the coverage tasks'
    task :run => ['coverage:report_to_codecov', 'coverage:clean']

    def codecov_cmd(codecov_url, codecov_token, derived_data_dir, vcs_number, branch, build_id)
        cmd = ['./tasks/lib/upload-coverage-to-codecov.sh']
        cmd.push('-v')
        cmd.push('-g', 'tasks/*')
        cmd.push('-u', codecov_url)
        cmd.push('-t', codecov_token)
        cmd.push('-C', vcs_number)

        if branch
            cmd.push('-B', branch) if branch

            pr_number = get_pr_number(branch)
            cmd.push('-P', pr_number) if pr_number
        end

        cmd.push('-b', build_id) if build_id
        cmd.push('-D', derived_data_dir) if derived_data_dir

        Shellwords.shelljoin(cmd)
    end

    def get_pr_number(branch_name)
        # Match the numeric part of the branch and select the entire match (#0).
        branch_name[/[0-9]+/, 0]
    end

end

desc 'Run the code coverage tasks'
task :coverage => 'coverage:run'
