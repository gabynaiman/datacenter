module Datacenter
  class Process

    ATTRIBUTES = [
      :command, 
      :status, 
      :memory, 
      :virtual_memory,
      :cpu,
      :user,
      :name,
      :cpu_usage,
      :mem_usage
    ]

    EXPIRATION_TIME = 2

    attr_reader :pid, :machine

    def initialize(pid, machine=nil)
      @pid = pid
      @machine = machine || Machine.new
      @cache = Cache.new EXPIRATION_TIME
    end

    ATTRIBUTES.each do |attribute|
      define_method attribute do
        info[attribute]
      end
    end

    def alive?
      send_signal 0
      true
    rescue Errno::ESRCH
      false
    end

    def send_signal(signal)
      out = machine.shell.run("kill -s #{signal} #{pid}")
      raise Errno::ESRCH, pid.to_s if out.match 'No such process'
    end

    def stop
      send_signal :TERM if alive?
    end

    def kill
      send_signal :KILL if alive?
      while alive?; end
    end

    private

    def info
      @cache.fetch(:info) do
        ps = machine.shell.run('ps aux').scan(/.*#{pid}.*/)[0].split
        Hash.new.tap do |info|
          status = Hash[proc_file(:status).split("\n").map{ |s| s.split(':').map(&:strip) }]
          info[:name] = status['Name']
          info[:user] = ps[0]
          info[:pid]  = ps[1]
          info[:cpu_usage] = ps[2].to_f
          info[:mem_usage] = ps[3].to_f
          info[:virtual_memory] = ps[4].to_i / 1024.0
          info[:memory] = ps[5].to_i / 1024.0
          info[:status] = ps[7] 
          info[:command] = ps[10..-1].reduce { |acum,e| "#{acum} #{e}" }
        end
      end
    end

    def proc_file(name)
      filename = File.join '/proc', pid.to_s, name.to_s
      machine.shell.run "cat #{filename}"
    end

  end
end
