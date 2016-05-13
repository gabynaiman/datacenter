module Datacenter
  module Shell
    class Local

      class SafeIO < SimpleDelegator
        def initialize(io)
          @io = io
          super StringIO.new
        end

        def write(message)
          super message
          @io.write message
        end
      end

      
      def initialize
        @mutex = Mutex.new
      end

      def run(command, options={})
        Datacenter.logger.debug(self.class) { command }

        opts = {
          chdir: options[:chdir] || Dir.pwd,
          out: options[:out] || StringIO.new,
          err: options[:err] || StringIO.new
        }

        if RUBY_ENGINE == 'jruby'
          run_system command, opts
        else
          run_open3 command, opts
        end
      end

      def self.open(*args)
        shell = new *args
        yield shell
      end

      private

      def run_open3(command, options)
        status = nil
        result = nil
        error = nil

        begin
          Open3.popen3("#{command}", chdir: options[:chdir]) do |stdin, stdout, stderr, wait_thr|
            status = wait_thr.value
            result = stdout.read
            error = stderr.read

            options[:out] << result
            options[:err] << error
          end
        rescue => ex
          raise CommandError.new(command, ex.message)
        end

        raise CommandError.new(command, error) unless status.success?

        result
      end

      def run_system(command, options)
        @mutex.synchronize do
          begin
            stdout = $stdout
            stderr = $stderr

            $stdout = SafeIO.new options[:out]
            $stderr = SafeIO.new options[:err]

            Dir.chdir(options[:chdir]) { system "#{command}" }

            status = $?

            $stdout.rewind
            $stderr.rewind
            
            result = $stdout.read.force_encoding('UTF-8')
            error = $stderr.read.force_encoding('UTF-8')

            raise CommandError.new(command, error) unless status.success?

            result

          ensure
            $stdout = stdout
            $stderr = stderr
          end
        end
      end

    end

   end 
end