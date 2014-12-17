require 'minitest_helper'

describe Datacenter::Shell do

  describe 'Local' do

    let(:shell) { Datacenter::Shell::Local.new }

    it 'Run' do
      filename = File.join '/tmp', Time.now.to_i.to_s
      shell.run "echo \"test file\" > #{filename}"
      shell.run("cat #{filename}").must_equal 'test file'
    end

  end

  describe 'Remote' do

    let(:connection_args) { ['localhost', `whoami`.strip] }

    it 'Run signle command' do
      shell = Datacenter::Shell::Remote.new *connection_args
      shell.run('ls /').must_equal `ls /`.strip
    end

    it 'Run block' do
      Datacenter::Shell::Remote.open(*connection_args) do |shell|
        shell.run('ls /').must_equal `ls /`.strip
      end
    end
    
  end

end