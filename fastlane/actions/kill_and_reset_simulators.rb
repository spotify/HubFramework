module Fastlane
  module Actions
    class KillAndResetSimulatorsAction < Action
      def self.run(params)
        system('pkill', '-9', '-x', 'Simulator')
        UI.success('Simulator app killed')
        Actions::ResetSimulatorsAction.run(params)
      end

      def self.description
        "Kills the Simulator before shutting down and resetting all simulators"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
