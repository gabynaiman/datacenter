require 'coverage_helper'
require 'minitest/autorun'
require 'minitest/colorin'
require 'yaml'
require 'datacenter'
require 'pry-nav'

class Module
  include Minitest::Spec::DSL
end

module Datacenter
  module Shell
    class Mock

      def initialize(file=nil)
        @commands = file ? YAML.load_file(file) : {}
      end

      def stub(command, value=nil, &block)
        commands[command] = value || block.call
      end

      def run(command)
        raise "Undefined command: #{command}" unless commands.key? command
        commands[command]
      end

      private

      attr_reader :commands

    end

  end
end

class Minitest::Spec
  let(:mock_shell) { Datacenter::Shell::Mock.new File.expand_path('../commands.yml', __FILE__) }
end