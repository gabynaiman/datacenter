module Datacenter
  module Shell

    class Localhost
      def run(command)
        `#{command}`.strip
      end
    end

    class Ssh
      attr_reader :ssh_args

      def initialize(*args)
        @ssh_args = args
      end

      def run(command)
        if @session
          @session.exec!(command).strip
        else
          Net::SSH.start(*@ssh_args) { |ssh| ssh.exec! command }.strip
        end
      end

      def open
        @session = Net::SSH.start *@ssh_args unless @session
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