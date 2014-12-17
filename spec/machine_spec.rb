require 'minitest_helper'

describe Datacenter::Machine do
 
  let(:machine) { Datacenter::Machine.new mock_shell }

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

  it ('List of Proccess') { machine.processes.find {|p| p.pid == 22803}.command.must_equal 'gnome-system-monitor' }
  
  it ('List of Proccess With Filter') { machine.processes('gnome-system-monitor').find {|p| p.pid == 22803}.name.must_equal 'gnome-system-mo' }

  it ('Top by Memory') { machine.top(:memory)[7].command.must_equal 'gnome-system-monitor' }

  it ('Top by CPU') { machine.top(:cpu)[0].command.must_equal 'gnome-system-monitor' }


  describe 'Disk Paritions' do
  
    it ('Size') { machine.disk_partitions.map(&:size).must_equal [296432.3671875, 286580.5556640625] }   
  
    it ('Available') { machine.disk_partitions.map(&:available).must_equal [276762.1953125, 203569.6171875] }   
  
    it ('Used') { machine.disk_partitions.map(&:used).must_equal [4612.2734375, 3864.20703125] }   
  
    it ('% Use') { machine.disk_partitions.map(&:used_percentage).must_equal [2, 15] }
  
    it ('Filesystem') { machine.disk_partitions.map(&:filesystem).must_equal ["/dev/sda1", "/dev/sdb1"] }
  
    it ('Type') { machine.disk_partitions.map(&:type).must_equal ["ext4", "ext4"] }
  
    it ('Mounted on') { machine.disk_partitions.map(&:mounted).must_equal ["/", "/sys"] }   
  end

end