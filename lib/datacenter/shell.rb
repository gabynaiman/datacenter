module Datacenter
  module Shell

    class Local

      def initialize
        @mutex = Mutex.new
      end

      def run(command)
        Datacenter.logger.debug(self.class) { command }
        if RUBY_ENGINE == 'jruby'
          run_system command
        else
          run_open3 command
        end
      end

      private

      def run_open3(command)
        i,o,e,t = Open3.popen3 command
        (o.readlines.join + e.readlines.join).strip
      end

      def run_system(command)
        @mutex.synchronize do
          begin
            $stdout = StringIO.new
            $stderr = StringIO.new

            system command

            [$stdout, $stderr].map do |io| 
              io.rewind
              io.readlines.join.force_encoding('UTF-8')
            end.join.strip

          ensure
            $stdout = STDOUT
            $stderr = STDERR
          end
        end
      end
    end

    class Remote
      attr_reader :options

      def initialize(*args)
        @options = args
      end

      def run(command)
        Datacenter.logger.debug(self.class) { command }
        if @session
          @session.exec!(command).strip
        else
          Net::SSH.start(*options) { |ssh| ssh.exec! command }.to_s.strip
        end
      end

      def open
        @session ||= Net::SSH.start *options
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