module Datacenter
  class Process

    ATTRIBUTES = [
      :command, 
      :status, 
      :memory, 
      :virtual_memory,
      :cpu,
      :user,
      :name
    ]

    attr_reader :pid
    attr_reader :machine

    def initialize(pid, machine=nil)
      @pid = pid
      @machine = machine
    end

    def alive?
      !(machine.shell.run 'ls /proc').scan("\n#{pid}\n").empty?
    end

    def mem_usage
      info[:pmem]
    end

    def cpu_usage
      info[:pcpu]
    end

    ATTRIBUTES.each do |attribute|
      define_method attribute do
        info[attribute]
      end
    end

    private

    # def info
    #   Hash.new.tap do |info|
    #     info[:command] = proc_file(:cmdline).tr("\000", ' ').strip

    #     Hash[proc_file(:status).split("\n").map{ |s| s.split(':').map(&:strip) }].tap do |status|
    #       info[:name] = status['Name']
    #       info[:status] = status['State']
    #       info[:memory] = status['VmRSS'].to_i / 1024
    #       info[:virtual_memory] = status['VmSize'].to_i / 1024
    #     end
    #   end
    # end

    def proc_dir
      "/proc/#{pid}"
    end

    def proc_file(file)
      machine.shell.run "cat #{File.join(proc_dir, file.to_s)}"
    end

    def info
      Hash.new.tap do |info|
        ps = machine.shell.run('ps aux').scan(/.*#{pid}.*/)[0].split
        status = Hash[proc_file(:status).split("\n").map{ |s| s.split(':').map(&:strip) }]
        info[:name] = status['Name']
        info[:user] = ps[0]
        info[:pid]  = ps[1]
        info[:pcpu] = ps[2].to_f
        info[:pmem] = ps[3].to_f
        info[:virtual_memory] = ps[4].to_i / 1024.0
        info[:memory] = ps[5].to_i / 1024.0
        info[:status] = ps[7]
        info[:command] = ps[10]
      end
    end
  end
end