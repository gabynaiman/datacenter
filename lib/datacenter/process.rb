module Datacenter
  class Process

    ATTRIBUTES = [
      :command, 
      :status, 
      :memory, 
      :virtual_memory,
      :cpu,
      :user
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

    def info
      Hash.new.tap do |info|
        ps = machine.shell.run('ps aux').scan(/.*#{pid}.*/)[0].split
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