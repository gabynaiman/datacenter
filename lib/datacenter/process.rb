module Datacenter
  class Process

    ATTRIBUTES = [
      :command, 
      :name, 
      :status, 
      :memory, 
      :virtual_memory,
      :cpu,
      :user
    ]

    attr_reader :pid

    def initialize(pid, shell=nil)
      @pid = pid
      @shell = shell || Shell::Localhost.new
    end

    def alive?
      !(shell.run 'ls /proc').scan("\n#{pid}\n").empty?
    end

    ATTRIBUTES.each do |attribute|
      define_method attribute do
        info[attribute]
      end
    end

    private

    attr_reader :shell

    def info
      Hash.new.tap do |info|
        info[:command] = proc_file(:cmdline).tr("\000", ' ').strip

        status = Hash[proc_file(:status).split("\n").map{ |s| s.split(':').map(&:strip) }]

        info[:name] = status['Name']
        info[:status] = status['State']
        info[:memory] = status['VmRSS'].to_i / 1024.0
        info[:virtual_memory] = status['VmSize'].to_i / 1024.0
        info[:cpu] = shell.run('ps aux').scan(/#{pid}.*/)[0].split[2]
        info[:user] = shell.run('ps aux').scan(/.*#{pid}.*/)[0].split[0]
      end
    end

    def proc_dir
      "/proc/#{pid}"
    end

    def proc_file(file)
      shell.run "cat #{File.join(proc_dir, file.to_s)}"
    end
  end
end