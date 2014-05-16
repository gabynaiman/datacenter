require 'coverage_helper'
require 'minitest/autorun'
require 'turn'
require 'yaml'
require 'datacenter'

Turn.config do |c|
  c.format = :pretty
  c.natural = true
  c.ansi = true
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