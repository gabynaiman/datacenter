module Datacenter
  class Machine

    attr_reader :shell

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

    def disk_partition
      Array.new.tap do |partition_list|
        partitions.each do |p|
          partition_list << (DiskPartition.new p)
        end
      end
    end

    def processes
      shell.run('ps aux').split("\n")[1..-1].map { |line| line.split }
                                            .map { |l| Datacenter::Process.new l[1],self }
    end

    def top(order)
      mappings = { memory:'rss', pid:'pid', cpu: '%cpu' }
      shell.run("ps aux --sort -#{mappings[order]}").split("\n")[1..-1].map { |line| line.split }
                                                        .map { |l| Datacenter::Process.new l[1],self }
    end 

    private    

    def partitions
      df = shell.run('df -lT').scan(/\/dev\/sd.*/).map { |e| e.split }
      Array.new.tap do |partition_list|
        df.each do |linea|
          p = {} 
          i = 0
          p[:filesystem]  = linea[i]
          p[:type]        = linea[i+=1]
          p[:size]        = linea[i+=1].to_i / 1024.0
          p[:used]        = linea[i+=1].to_i / 1024.0
          p[:available]   = linea[i+=1].to_i / 1024.0
          p[:p_use]       = linea[i+=1].to_f
          p[:mounted]     = linea[i+=1]
          partition_list << p        
        end
      end
    end

    def meminfo
      Hash[shell.run('cat /proc/meminfo').split("\n").map { |e| e.split(':').map(&:strip) }]
    end

    class DiskPartition
      attr_reader :filesystem, :type, :size, :used, :available, :p_use, :mounted

      def initialize(attributes)
        attributes.each do |name, value|
          instance_variable_set "@#{name}", value if respond_to? name
        end
      end
    end
  end
end