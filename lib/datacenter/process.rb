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

    attr_reader :pid

    def initialize(pid, shell=nil)
      @pid = pid
      @shell = shell || Shell::Local.new
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
      out = shell.run("kill -s #{signal} #{pid}")
      raise Errno::ESRCH, pid.to_s if out.match 'No such process'
    end

    def stop
      send_signal :QUIT if alive?
    end

    def kill
      send_signal :KILL if alive?
      while alive?; end
    end

    private

    attr_reader :shell

    def info
      @cache.fetch(:info) do
        ps = shell.run('ps aux').scan(/.*#{pid}.*/)[0].split
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
      shell.run "cat #{filename}"
    end

  end
end
