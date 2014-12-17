require 'minitest_helper'

describe Datacenter::Shell do

  describe 'Remote' do

    let(:shell) { Datacenter::Shell::Remote.new 'localhost', `whoami`.strip }

    before { shell.open }
    after { shell.close }

    it 'Run' do
      shell.run('ls /').must_equal `ls /`.strip
    end
    
  end

end