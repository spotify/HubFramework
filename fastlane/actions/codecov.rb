require 'shellwords'
require 'tempfile'

module Fastlane
  module Actions
    class CodecovAction < Action
      def self.run(params)
        dd_path = params[:derived_data_path] || Actions.lane_context[:SCAN_DERIVED_DATA_PATH]
        UI.user_error!("Invalid derived_data_path") unless dd_path

        cc_url = params[:url]
        cc_token = params[:token]
        pr = (branch || '').scan(/pull\/(\d+)\//).flatten.first

        UI.message("Collecting coverage for the branch '#{branch}'")
        UI.message("Branch is for PR##{pr}") if not pr.to_s.empty?

        script = Tempfile.new('codecov')
        begin
          script_url = "#{cc_url}/bash"
          sh!('curl', '-sf', script_url, '-o', script.path)
          sh!('chmod', '+x', script.path)

          invocation_args = [
            script.path,
            '-X', 'gcov', '-X', 'coveragepy',
            '-u', cc_url,
            '-D', dd_path,
            '-P', pr
          ]
          # The token is optional for certain CI environments.
          invocation_args.push('-t', cc_token) unless not cc_token.to_s.empty?
          Actions.sh(invocation_args)
        ensure
          script.close
          script.unlink
        end
      end

      def self.branch
        pr_branch = ENV['TRAVIS_PULL_REQUEST_BRANCH'].to_s
        return pr_branch if not pr_branch.empty? and pr_branch != "false"
        return Actions::GitBranchAction.run({})
      end

      def self.sh!(*args)
        Actions.sh(Shellwords.shelljoin(args))
      end

      def self.description
        "Uploads processed data to Codecov"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :token,
                                       env_name: "CODECOV_TOKEN",
                                       description: "The Codecov upload token, optional in certain CI environments",
                                       optional: true),

          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "CODECOV_URL",
                                       description: "The URL of the Codecov instance",
                                       default_value: "https://codecov.io"),
 
          FastlaneCore::ConfigItem.new(key: :derived_data_path,
                                       env_name: "CODECOV_DERIVED_DATA_PATH",
                                       description: "Path to the derived data directory",
                                       optional: true),
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
