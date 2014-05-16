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

      it ('Cores') { machine.cores.must_equal 2 }

      it ('Total Memory') { machine.memory.must_equal 4039632/1024.0 }

      it ('Free Memory') { machine.memory_free.must_equal 1293268/1024.0 }

      it ('Used Memory') { machine.memory_used.must_equal 4039632/1024.0 - 1293268/1024.0 }

      it ('Total Swap') { machine.swap.must_equal 4183036/1024.0 }

      it ('Free Swap') { machine.swap_free.must_equal 4183036/1024.0 }
      
      it ('Used Swap') { machine.swap_used.must_equal 4183036/1024.0 - 4183036/1024.0 }
   
      it ('Total Disk') { machine.disk_size.must_equal 303546744/1024.0 }

      it ('Used Disk') { machine.disk_used.must_equal 4956120/1024.0 }

      it ('Available Disk') { machine.disk_available.must_equal 283171336/1024.0 } 
      
      it ('List of Proccess') { machine.processes.find {|p| p.pid=="22803"}.name.must_equal 'gnome-system-mo' }

      it ('Top by Memory') { machine.top(:memory)[7].command.must_equal 'gnome-system-monitor' }

      it ('Top by CPU') { machine.top(:cpu)[0].command.must_equal 'gnome-system-monitor' }
    end

    describe Datacenter::Process do

      let(:pid) { 22803 }
      let(:shell) { Datacenter::Shell::Mock.new COMMANDS_FILE }
      let(:process) { Datacenter::Process.new pid, shell }

      it ('Pid') { process.pid.must_equal pid }

      it ('Alive') { process.alive?.must_equal true }

      it 'Dead' do
        process = Datacenter::Process.new -1
        process.alive?.must_equal false
      end

      it ('Name') { process.name.must_equal 'gnome-system-mo' }

      it ('Command') { process.command.must_equal 'gnome-system-monitor' }

      it ('Memory') { process.memory.must_equal 31864/1024.0 }

      it ('Virtual Memory') { process.virtual_memory.must_equal 511312/1024.0 }

      it ('% Memory') #not implemented

      it ('% CPU') #not implemented

      it ('Status') { process.status.must_equal 'S (sleeping)' }

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