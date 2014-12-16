require 'minitest_helper'

describe Datacenter::Process do

  let(:pid) { 22803 }
  let(:machine) { Datacenter::Machine.new mock_shell }
  let(:process) { Datacenter::Process.new pid, machine }

  it ('Pid') { process.pid.must_equal pid }

  it ('Alive') { process.alive?.must_equal true }

  it 'Dead' do
    process = Datacenter::Process.new -123
    process.wont_be :alive?
  end

  it ('Name') { process.name.must_equal 'gnome-system-mo' }
  
  it ('Command') { process.command.must_equal 'gnome-system-monitor' }

  it ('Memory') { process.memory.must_equal 33.0 }

  it ('Virtual Memory') { process.virtual_memory.must_equal 501.23828125 }

  it ('% Memory') { process.mem_usage.must_equal 0.8 }

  it ('% CPU') { process.cpu_usage.must_equal 11.9 }

  it ('Status') { process.status.must_equal 'Sl' }

  it ('User') { process.user.must_equal 'matias' }

end