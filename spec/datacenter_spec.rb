require 'minitest_helper'

describe Datacenter do

  COMMANDS_FILE = File.join(File.dirname(__FILE__), 'commands.yml')

  describe Datacenter::OS do

    let(:shell) { Datacenter::Shell::Mock.new  COMMANDS_FILE }
    let(:os) { Datacenter::OS.new shell }

    it ('Name') { os.name.must_equal 'GNU/Linux' }
    
    it ('Distribution') { os.distribution.must_equal 'Ubuntu' }
    
    it ('Version') { os.version.must_equal '12.04' }
    
    it ('Kernel') { os.kernel.must_equal '3.5.0-49-generic' }
    
    it ('Platform') { os.platform.must_equal 'x86_64' }

  end

  describe Datacenter::Machine do
   
    describe 'Local' do
      
      let(:shell) { Datacenter::Shell::Mock.new COMMANDS_FILE }
      let(:machine) { Datacenter::Machine.new shell}

      it ('IPs') { machine.ips.must_equal %w(192.168.50.127 127.0.0.1) }

      it ('Name') { machine.name.must_equal "matias" }

      it 'OS' do
        machine.os.name.must_equal 'GNU/Linux'
        machine.os.distribution.must_equal 'Ubuntu'
        machine.os.version.must_equal '12.04'
      end

      it ('CPU') { machine.cpu.must_equal 'Intel(R) Core(TM)2 Duo CPU     E7500  @ 2.93GHz'}

      it ('Cores') { machine.cores.must_equal 2 }

      it ('Total Memory') { machine.memory.must_equal 3944.953125 }

      it ('Free Memory') { machine.memory_free.must_equal 1262.95703125 }

      it ('Used Memory') { machine.memory_used.must_equal 2681.99609375 }

      it ('Total Swap') { machine.swap.must_equal 4084.99609375 }

      it ('Free Swap') { machine.swap_free.must_equal 4084.99609375 }
      
      it ('Used Swap') { machine.swap_used.must_equal 0.0}

      it ('List of Proccess') { machine.processes.find {|p| p.pid=="22803"}.command.must_equal 'gnome-system-monitor' }

      it ('Top by Memory') { machine.top(:memory)[7].command.must_equal 'gnome-system-monitor' }

      it ('Top by CPU') { machine.top(:cpu)[0].command.must_equal 'gnome-system-monitor' }

      describe 'Disk Paritions' do
        it ('Size') { machine.disk_partition.map(&:size).must_equal [296432.3671875,286580.5556640625] }   
        it ('Available') { machine.disk_partition.map(&:available).must_equal [276762.1953125,203569.6171875] }   
        it ('Used') { machine.disk_partition.map(&:used).must_equal [4612.2734375,3864.20703125] }   
        it ('%Use') { machine.disk_partition.map(&:p_use).must_equal [2,15] }          
        it ('Filesystem') { machine.disk_partition.map(&:filesystem).must_equal ["/dev/sda1","/dev/sdb1"] }   
        it ('Type') { machine.disk_partition.map(&:type).must_equal ["ext4","ext4"] }   
        it ('Mounted on') { machine.disk_partition.map(&:mounted).must_equal ["/","/sys"] }   
      end
    end

    describe Datacenter::Process do

      let(:pid) { 22803 }
      let(:shell) { Datacenter::Shell::Mock.new COMMANDS_FILE }
      let(:machine) { Datacenter::Machine.new shell}
      let(:process) { Datacenter::Process.new pid,machine }

      it ('Pid') { process.pid.must_equal pid }

      it ('Alive') { process.alive?.must_equal true }

      it 'Dead' do
        process = Datacenter::Process.new -1,machine
        process.alive?.must_equal false
      end

      it ('Name') { process.name.must_equal 'gnome-system-mo' }
      
      it ('Command') { process.command.must_equal 'gnome-system-monitor' }

      it ('Memory') { process.memory.must_equal 33.0 }
 
      it ('Virtual Memory') { process.virtual_memory.must_equal 501.23828125 }
 
      it ('% Memory') { process.mem_usage.must_equal 0.8}

      it ('% CPU') { process.cpu_usage.must_equal 11.9 }

      it ('Status') { process.status.must_equal 'Sl' }

      it ('User') { process.user.must_equal 'matias' }

    end

  end

  describe Datacenter::Shell::Ssh do

    let(:shell) { Datacenter::Shell::Ssh.new 'localhost', `whoami`.strip }

    before { shell.open }
    after { shell.close }

    it 'Run' do
      shell.run('ls /').must_equal `ls /`.strip
    end
  end

end