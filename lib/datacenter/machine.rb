module Datacenter
  class Machine

    attr_reader :shell

    def initialize(shell=nil)
      @shell = shell || Shell::Local.new
    end

    def ips
      shell.run('ifconfig')
           .scan(/inet addr:(([0-9]*\.){3}[0-9]*)/)
           .map { |s| s[0] }
    end

    def name
      shell.run('hostname').strip
    end

    def os
      @os ||= OS.new shell
    end
    
    def cpu
      cpuinfo['model name']
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

    def disk_partitions
      partitions.map { |p| DiskPartition.new p }
    end

    def processes(filter='')
      if filter.empty?
        command = 'ps aux'
        start = 1
      else
        command = "ps aux | grep \"#{filter}\" | grep -v grep"
        start =  0
      end
      shell.run(command)
           .split("\n")[start..-1]
           .map { |l| Datacenter::Process.new l.split[1].to_i, self }
    end

    def top(order, n=10)
      mappings = {memory: 'rss', pid: 'pid', cpu: '%cpu'}
      shell.run("ps aux --sort -#{mappings[order]} | head -n #{n+1}")
           .split("\n")[1..-1]
           .map { |l| Datacenter::Process.new l.split[1], self }
    end

    private    

    def partitions
      shell.run('df -lT')
           .scan(/^\/dev.*/)
           .map do |p|
             line = p.split
             {
               filesystem:      line[0],
               type:            line[1],
               size:            line[2].to_f / 1024,
               used:            line[3].to_f / 1024,
               available:       line[4].to_f / 1024,
               used_percentage: line[5].to_f,
               mounted:         line[6]
             }
           end
    end

    def meminfo
      Hash[shell.run('cat /proc/meminfo').split("\n").map { |e| e.split(':').map(&:strip) }]
    end

    def cpuinfo
      Hash[shell.run('cat /proc/cpuinfo').split("\n").select {|e| e.length>0}.map { |e| e.split(':').map(&:strip) }]
    end

    class DiskPartition
      attr_reader :filesystem, :type, :size, :used, :available, :used_percentage, :mounted

      def initialize(attributes)
        attributes.each do |name, value|
          instance_variable_set "@#{name}", value if respond_to? name
        end
      end
    end
  end
end
