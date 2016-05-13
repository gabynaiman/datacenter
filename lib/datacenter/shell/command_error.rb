module Datacenter
  module Shell
    class CommandError < StandardError

      attr_reader :command, :error

      def initialize(command, error)
        @command = command
        @error = error
      end

      def message
        "#{command}\n#{error}"
      end

    end
  end
end