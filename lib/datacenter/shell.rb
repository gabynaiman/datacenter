module Datacenter
  module Shell

    class Localhost
      def run(command)
        `#{command}`.strip
      end
    end

    class Ssh
      attr_reader :options

      def initialize(*args)
        @options = args
      end

      def run(command)
        if @session
          @session.exec!(command).strip
        else
          Net::SSH.start(*options) { |ssh| ssh.exec! command }.strip
        end
      end

      def open
        @session = Net::SSH.start *options unless @session
      end

      def close
        if @session
          @session.close
          @session = nil
        end
      end

      def self.open(*args, &block)
        shell = new *args
        shell.open
        block.call shell
        shell.close
      end
    end

  end
end