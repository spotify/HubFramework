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
        pr = (Actions::GitBranchAction.run({}) || '').scan(/pull\/(\d+)\//).flatten.first

        script = Tempfile.new('codecov')
        begin
          script_url = "#{cc_url}/bash"
          sh!('curl', '-sf', script_url, '-o', script.path)
          sh!('chmod', '+x', script.path)
          sh!(
            script.path, '-v', '-X', 'gcov', '-X', 'coveragepy',
            '-u', cc_url, '-t', cc_token, '-D', dd_path, '-P', pr
          )
        ensure
          script.close
          script.unlink
        end
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
                                       description: "The Codecov upload token"),

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
