module Datacenter
  class Machine

    def initialize(shell=nil)
      @shell = shell || Shell::Localhost.new
    end

    def ips
      shell.run('ifconfig')
           .scan(/inet addr:(([0-9]*\.){3}[0-9]*)/)
           .map { |s| s[0] }
    end

    def name
      (shell.run 'hostname').strip
    end

    def os
      @os ||= OS.new shell
    end

    def cores
      shell.run('nproc').to_i
    end

    def memory
      meminfo['MemTotal'].to_i / 1024.0
    end

    def memory_free
      meminfo['MemFree'].to_i / 1024.0
    end

    def memory_used
      memory - memory_free
    end

    def swap
      meminfo['SwapTotal'].to_i / 1024.0
    end

    def swap_free
      meminfo['SwapFree'].to_i / 1024.0
    end

    def swap_used
      swap - swap_free
    end

    def disk_size
      diskinfo[:size] / 1024.0
    end

    def disk_used
      diskinfo[:used] / 1024.0
    end

    def disk_available
      diskinfo[:available] / 1024.0
    end

    def processes
      shell.run('ps aux').split("\n")[1..-1].map { |line| line.split }
                                           .map { |l| Datacenter::Process.new l[1],shell }
    end

    def top(order)
      mappings = { memory:'rss', pid:'pid', cpu: '%cpu' }
      shell.run("ps aux --sort -#{mappings[order]}").split("\n")[1..-1].map { |line| line.split }
                                                        .map { |l| Datacenter::Process.new l[1],shell }
    end 

    private

    attr_reader :shell

    def meminfo
      Hash[shell.run('cat /proc/meminfo').split("\n").map { |e| e.split(':').map(&:strip) }]
    end

    def diskinfo
      info = shell.run('df -l').split("\n")
                                .map {|e| e.split}
                                .find {|s| s[5]=="\/"};
      
      Hash[{size: info[1].to_f, used: info[2].to_f, available: info[3].to_f}]
    end

  end
end