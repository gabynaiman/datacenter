module Datacenter
  module Shell

    class Local
      def run(command)
        i,o,e,t = Open3.popen3 command
        (o.readlines.join + e.readlines.join).strip
      end
    end

    class Remote
      attr_reader :options

      def initialize(*args)
        @options = args
      end

      def run(command)
        if @session
          @session.exec!(command).strip
        else
          Net::SSH.start(*options) { |ssh| ssh.exec! command }.to_s.strip
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