module Fastlane
  module Actions
    class LintSourcesForLicenseHeaderAction < Action

      def self.run(params)
        shellwords = [
          "./fastlane/scripts/lint_license_conformance",
          params[:template],
        ]
        shellwords.concat(params[:files])

        sh(Shellwords.shelljoin(shellwords), print_command: false)
      end

      def self.description
          "Validate that all of the given license files begin with the license header in the given template"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :template,
                                       env_name: "LINT_LICENSE_HEADER_TEMPLATE_PATH",
                                       description: "The path to the license header template file"),

          FastlaneCore::ConfigItem.new(key: :files,
                                       description: "An array containing the path to each file that should be linted",
                                       env_name: "LINT_LICENSE_HEADER_FILES",
                                       is_string: false),
        ]
      end

      def self.is_supported?(platform)
        true
      end

    end
  end
end
