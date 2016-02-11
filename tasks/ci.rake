require 'set'
require 'shellwords'
require 'tc_util'

SIM_DEVICE_DEFAULT='iPhone 6s'
SIM_OS_DEFAULT='9.2'

DERIVED_DATA_PATH='build/DerivedData'

# Task which builds and tests the
namespace :ci do

    desc 'Clean the build directory'
    task :clean_build_dir do
        system('rm', '-rf', 'build') or exit!(1)
    end

    desc 'Create the build directory'
    task :create_build_dir => ['ci:clean_build_dir'] do
        system('mkdir', '-p', 'build') or exit!(1)
    end

    desc 'Builds and runs all the tests'
    task :build_and_test do
        sim_device = ENV['SIM_DEVICE'] || SIM_DEVICE_DEFAULT
        sim_os = ENV['SIM_OS'] || SIM_OS_DEFAULT

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
            sim_device,
            sim_os,
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

    desc 'Run the CI bound tasks (build, test, upload code coverage)'
    task :run => [:clean_build_dir, :create_build_dir, :build_and_test] do
        ENV['DERIVED_DATA_PATH'] = DERIVED_DATA_PATH
        Rake::Task['coverage:run'].invoke
    end

    def build_cmd(project, scheme, configuration, sim_device, sim_os, generate_coverage, commands)
        cmd = ['xcodebuild']
        cmd.push(*commands)
        cmd.push('-project', project)
        cmd.push('-configuration', configuration)
        cmd.push('-scheme', scheme)
        cmd.push('-sdk', 'iphonesimulator')
        cmd.push('-derivedDataPath', DERIVED_DATA_PATH)
        cmd.push('-destination', "platform=iOS Simulator,name=#{sim_device},OS=#{sim_os}")
        cmd.push('-enableCodeCoverage', 'YES') if generate_coverage

        Shellwords.shelljoin(cmd)
    end

end

desc 'Run the CI tasks'
task :ci => 'ci:run'
