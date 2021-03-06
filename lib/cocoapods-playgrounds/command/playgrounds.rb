require 'xcodeproj'

module Pod
  class Command
    class Playgrounds < Command
      DEFAULT_PLATFORM_NAME = :ios

      self.summary = 'Generates a Swift Playground for any Pod.'

      self.description = <<-DESC
        Generates a Swift Playground for any Pod.
      DESC

      self.arguments = [CLAide::Argument.new('NAMES', true)]

      def self.options
        [
          ['--no-install', 'Skip running `pod install`'],
          ['--platform', "Platform to generate for (default: #{DEFAULT_PLATFORM_NAME})"],
          ['--platform_version', 'Platform version to generate for ' \
            "(default: #{default_version_for_platform(DEFAULT_PLATFORM_NAME)})"]
        ]
      end

      def self.default_version_for_platform(platform)
        Xcodeproj::Constants.const_get("LAST_KNOWN_#{platform.upcase}_SDK")
      end

      def initialize(argv)
        arg = argv.shift_argument
        @names = arg.split(',') if arg
        @install = argv.flag?('install', true)
        @platform = argv.option('platform', DEFAULT_PLATFORM_NAME).to_sym
        @platform_version = argv.option('platform_version', Playgrounds.default_version_for_platform(@platform))
        @use_legacy_xcode = is_legacy_xcode?
        super
      end

      def validate!
        super
        help! 'At least one Pod name is required.' unless @names
      end

      def is_legacy_xcode?
        %x( xcodebuild -version ).include? "Xcode 7"
      end

      def run
        # TODO: Pass platform and deployment target from configuration
        generator = WorkspaceGenerator.new(@names, :cocoapods, @platform, @platform_version, @use_legacy_xcode)
        generator.generate(@install)
      end
    end
  end
end
