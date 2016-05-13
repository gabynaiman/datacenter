require 'net/ssh'
require 'open3'
require 'class_config'
require 'logger'
require 'delegate'

module Datacenter
  extend ClassConfig
  attr_config :logger, Logger.new('/dev/null')
  attr_config :process_cache_expiration, 2
end

Dir.glob(File.expand_path('datacenter/**/*.rb', File.dirname(__FILE__))).sort.each { |f| require f }