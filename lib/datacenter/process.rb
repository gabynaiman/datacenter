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

    TIME_CACHE = 2

    attr_reader :pid, :machine, :cache

    def initialize(pid, machine=nil)
      @pid = pid
      @machine = machine || Machine.new
      @cache = {fetched: 0, content: []}      
    end

    def alive?
      !(machine.shell.run 'ls /proc').scan("\n#{pid}\n").empty?
    end

    def send_signal(signal)
      ::Process.kill signal, pid
    rescue Errno::ESRCH
      nil
    end

    def stop
      send_signal :TERM
    end

    def kill
      send_signal :KILL
      while alive?; end
    end

    ATTRIBUTES.each do |attribute|
      define_method attribute do
        info[attribute]
      end
    end

    private

    def info
      if cache[:content].empty? || (Time.now - cache[:fetched] > TIME_CACHE)
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
          @cache = {fetched: Time.now, content: info}
        end
      else
        cache[:content]
      end      
    end

    def proc_dir
      "/proc/#{pid}"
    end

    def proc_file(file)
      machine.shell.run "cat #{File.join(proc_dir, file.to_s)}"
    end

  end
end
