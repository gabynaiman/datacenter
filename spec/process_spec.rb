require 'minitest_helper'

describe Datacenter::Process do

  let(:pid) { 22803 }
  let(:process) { Datacenter::Process.new pid, mock_shell }

  it ('Pid') { process.pid.must_equal pid }

  it ('Alive') { process.must_be :alive? }

  it ('Dead') { Datacenter::Process.new(-pid, mock_shell).wont_be :alive? }

  it ('Stop') { process.stop }

  it ('Kill') { Datacenter::Process.new(pid, Datacenter::Shell::Kill.new(pid)).kill }

  it ('Name') { process.name.must_equal 'gnome-system-mo' }
  
  it ('Command') { process.command.must_equal 'gnome-system-monitor' }

  it ('Memory') { process.memory.must_equal 33.0 }

  it ('Virtual Memory') { process.virtual_memory.must_equal 501.23828125 }

  it ('% Memory') { process.mem_usage.must_equal 0.8 }

  it ('% CPU') { process.cpu_usage.must_equal 11.9 }

  it ('Status') { process.status.must_equal 'Sl' }

  it ('User') { process.user.must_equal 'matias' }

end