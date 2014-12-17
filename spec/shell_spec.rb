require 'minitest_helper'

describe Datacenter::Shell do
  
  module SharedExpamples
    it 'Success' do
      filename = File.join '/tmp', Time.now.to_i.to_s
      shell.run "echo \"test file\" > #{filename}"
      shell.run("cat #{filename}").must_equal 'test file'
    end

    it 'Error' do
      filename = '/invalid_dir/invalid_file'
      shell.run("cat #{filename}").must_equal "cat: #{filename}: No such file or directory"
    end
  end

  describe 'Local' do

    let(:shell) { Datacenter::Shell::Local.new }

    include SharedExpamples

  end

  describe 'Remote' do

    let(:connection_args) { ['localhost', `whoami`.strip] }
    let(:shell) { Datacenter::Shell::Remote.new *connection_args }

    include SharedExpamples

    it 'Block' do
      Datacenter::Shell::Remote.open(*connection_args) do |shell|
        shell.run('ls /').must_equal `ls /`.strip
      end
    end

  end

end