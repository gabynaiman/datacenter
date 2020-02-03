module Datacenter
  module Shell
    class Remote
      
      def initialize(*args)
        @args = args
      end

      def open
        @session ||= Net::SSH.start(*args)
      end

      def close
        if session && !session.closed?
          session.close
          @session = nil
        end
      end

      def run(command, options={})
        if session
          run! command, options
        else
          self.class.open(*args) { |shell| shell.run command, options }
        end
      end

      def self.open(*args)
        shell = new(*args)
        shell.open
        yield shell
      ensure
        shell.close
      end

      private

      attr_reader :args, :session

      def run!(command, options={})
        Datacenter.logger.debug(self.class) { command }

        result = ''
        error = ''
        
        out = options[:out] || StringIO.new
        err = options[:err] || StringIO.new

        exit_code = nil

        session.open_channel do |channel|
          channel.exec(command) do |ch, success|
            abort "FAILED: couldn't execute command (ssh.channel.exec)" unless success
            
            channel.on_data do |ch, data|
              out << data
              result << data
            end

            channel.on_extended_data do |ch, type, data|
              err << data
              error << data
            end

            channel.on_request('exit-status') do |ch, data|
              exit_code = data.read_long
            end
          end
        end

        session.loop

        raise CommandError.new(command, error) unless exit_code == 0

        result
      end

    end
  end
end