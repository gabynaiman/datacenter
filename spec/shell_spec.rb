require 'minitest_helper'

describe Datacenter::Shell do
  
  module SharedExpamples

    let(:shell) { shell_class.new *shell_args }
    
    it 'Success' do
      filename = File.join '/tmp', Time.now.to_i.to_s
      shell.run "echo \"test file\" > #{filename}"
      shell.run("cat #{filename}").must_equal "test file\n"
    end

    it 'Error' do
      filename = '/invalid_dir/invalid_file'
      error = Proc.new { shell.run("cat #{filename}") }.must_raise Datacenter::Shell::CommandError
      error.message.must_include "cat: #{filename}: No such file or directory"
    end

    it 'Block' do
      shell_class.open(*shell_args) do |shell|
        shell.run('ls /').must_equal `ls /`
      end
    end

  end

  describe 'Local' do

    let(:shell_args) { [] }
    let(:shell_class) { Datacenter::Shell::Local }

    include SharedExpamples

  end

  describe 'Remote' do

    let(:shell_args) { ['localhost', `whoami`.strip] }
    let(:shell_class) { Datacenter::Shell::Remote }

    include SharedExpamples

  end

end