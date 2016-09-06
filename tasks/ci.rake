require 'set'
require 'shellwords'
require 'simulator_ci'
require 'tc_util'

DERIVED_DATA_PATH='build/DerivedData'

# Task which builds and tests the
namespace :ci do

    def simulator_kill_reset
        Simulator.kill_all!
        Simulator.ci_device.shutdown!
        Simulator.ci_device.erase!
    end

    desc 'Prepare the build directory for a new build'
    task :prepare_build_dir do
        system('rm', '-rf', 'build')
        system('mkdir', '-p', 'build')
    end

    desc 'Prepare environment for running simulator'
    task :prepare_simulator do
        simulator_kill_reset
    end

    desc 'Perform simulator cleanup'
    task :cleanup_simulator do
        simulator_kill_reset
    end

    desc 'Builds and runs all the tests'
    task :build_and_test do
        build_commands = [
            'clean',
            'build',
            'analyze',
            'test'
        ]

        cmd = build_cmd(
            'HubFramework.xcodeproj',
            'HubFramework',
            'Debug',
            true,
            build_commands
        )

        # Workaround for xcodebuild output arriving out-of-order. Also required when piping
        # xcodebuild output.
        ENV['NSUnbufferedIO'] = 'YES'

        TCUtil.block('Build, analyze and test') do
            puts "Executing \"#{cmd}\""
            system cmd or exit!(1)
        end
    end

    desc 'Calculate code coverage from the derived data folder.'
    task :coverage do
        token = ENV['CODECOV_TOKEN']
        host = ENV['CODECOV_HOST']
        url = ENV['CODECOV_URL'] || (host ? "https://#{host}" : nil)
        unless token && url
          puts "Codecov info missing. Not posting coverage."
          next
        end

        command = ['./scripts/codecov.sh', '-v', '-X', 'gcov', '-X', 'coveragepy']
        command << '-d' if ENV['CODECOV_DRYRUN'] == '1'
        {
          '-u' => url,
          '-t' => token,
          '-D' => DERIVED_DATA_PATH,
          '-P' => ENV.fetch('TEAMCITY_BUILD_BRANCH', '').scan(/pull\/(\d+)/).flatten.first,
        }.each{|k,v| command.push(k.to_s, v.to_s) if v }

        # Run command
        full_cmd = Shellwords.shelljoin(command)
        puts full_cmd
        system(full_cmd) or abort("CodeCov POST Failed!: #{$?}")
    end

    desc 'Run the CI bound tasks (build, test, upload code coverage)'
    task :run => [:prepare_build_dir, :prepare_simulator, :build_and_test, :coverage, :cleanup_simulator]

    def build_cmd(project, scheme, configuration, generate_coverage, commands)
        device = Simulator.ci_device

        # pre-launch the device if testing
        if commands.include?('test')
            device.launch_fresh!
        end

        cmd = ['xcodebuild']
        cmd.push(*commands)
        cmd.push('-project', project)
        cmd.push('-configuration', configuration)
        cmd.push('-scheme', scheme)
        cmd.push('-sdk', 'iphonesimulator')
        cmd.push('-derivedDataPath', DERIVED_DATA_PATH)
        cmd.push('-destination', Simulator.ci_device.destination)
        cmd.push('-enableCodeCoverage', 'YES') if generate_coverage

        Shellwords.shelljoin(cmd)
    end

end

desc 'Run the CI tasks'
task :ci => 'ci:run'
