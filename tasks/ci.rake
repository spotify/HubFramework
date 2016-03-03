require 'profdata'
require 'set'
require 'shellwords'
require 'tc_util'

SIM_DEVICE_DEFAULT='iPhone 6s'
SIM_OS_DEFAULT='9.2'

DERIVED_DATA_PATH='build/DerivedData'

# Task which builds and tests the
namespace :ci do

    desc 'Prepare the build directory for a new build'
    task :prepare_build_dir do
        system('rm', '-rf', 'build')
        system('mkdir', '-p', 'build')
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

    desc 'Calculate code coverage from the derived data folder.'
    task :coverage do
        TCUtil.block('Code Coverage') do
            # Calculate coverage
            pd = Profdata.from_derived_data(DERIVED_DATA_PATH)

            # Report to TeamCity
            total, covered = pd.stats
            TCUtil.stat('CodeCoverageAbsLCovered', covered)
            TCUtil.stat('CodeCoverageAbsLCovered', total)
            TCUtil.stat('CodeCoverageAbsLPerMille', (covered.to_f / total) * 1000)

            # Report to codecov
            if ENV['CODECOV_TOKEN'] && ENV['CODECOV_URL']
                # Create JSON file
                pd.write_codecov_file('build/codecov.json')
                info = TCUtil.info

                # Skip CodeCov adjustments since we do them ourself
                command = ['./scripts/codecov.sh', '-v', '-X', 'fix']
                {
                    '-u' => ENV['CODECOV_URL'],
                    '-t' => ENV['CODECOV_TOKEN'],
                    '-f' => 'build/codecov.json',
                    '-C' => info[:commit],
                    '-B' => info[:branch],
                    '-P' => info[:pr],
                    '-b' => info[:build_id]
                }.each{|k,v| command.push(k.to_s, v) if v }

                # Run command
                env = { 'GIT_BRANCH' => info[:branch], 'GIT_COMMIT' => info[:commit] }
                system(env, *command) or abort("CodeCov POST Failed!: #{$?}")
            end
        end
    end

    desc 'Run the CI bound tasks (build, test, upload code coverage)'
    task :run => [:prepare_build_dir, :build_and_test, :coverage]

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
