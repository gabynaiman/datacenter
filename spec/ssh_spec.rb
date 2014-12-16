require 'minitest_helper'

describe Datacenter::Shell::Ssh do

  let(:shell) { Datacenter::Shell::Ssh.new 'localhost', `whoami`.strip }

  before { shell.open }
  after { shell.close }

  it 'Run' do
    shell.run('ls /').must_equal `ls /`.strip
  end
  
end