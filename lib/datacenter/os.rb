module Datacenter
  class OS

    def initialize(shell=nil)
      @shell = shell || Shell::Localhost.new
    end

    def name
      shell.run 'uname -o'
    end

    def distribution
      shell.run('lsb_release -i').split(':')[1].strip
    end

    def version
      shell.run('lsb_release -r').split(':')[1].strip
    end

    def kernel
      shell.run 'uname -r'
    end

    def platform
      shell.run 'uname -i'
    end

    private

    attr_reader :shell
    
  end
end