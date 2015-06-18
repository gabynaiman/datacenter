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

    attr_reader :pid

    def initialize(pid, shell=nil)
      @pid = pid
      @shell = shell || Shell::Local.new
      @cache = Cache.new Datacenter.process_cache_expiration
    end

    ATTRIBUTES.each do |attribute|
      define_method attribute do
        info[attribute]
      end
    end

    def alive?
      alive = !shell.run("ps -p #{pid} | grep #{pid}").empty?
      Datacenter.logger.info(self.class) { "pid: #{pid} - ALIVE: #{alive}" } if !alive
      alive
    end

    def send_signal(signal)
      shell.run "kill -s #{signal} #{pid}"
    end

    private

    attr_reader :shell

    def info
      @cache.fetch(:info) do
        status = Hash[proc_file(:status).split("\n").map{ |s| s.split(':').map(&:strip) }]
        ps = shell.run("ps -p #{pid} -o user,pid,pcpu,%mem,vsize,rss,stat,command").split("\n")[1].split
        Hash.new.tap do |info|
          info[:name] = status['Name']
          info[:user] = ps[0]
          info[:pid]  = ps[1]
          info[:cpu_usage] = ps[2].to_f
          info[:mem_usage] = ps[3].to_f
          info[:virtual_memory] = ps[4].to_i / 1024.0
          info[:memory] = ps[5].to_i / 1024.0
          info[:status] = ps[6]
          info[:command] = ps[7..-1].reduce { |acum,e| "#{acum} #{e}" }
        end
      end
    end

    def proc_file(name)
      filename = File.join '/proc', pid.to_s, name.to_s
      shell.run "cat #{filename}"
    end

  end
end
