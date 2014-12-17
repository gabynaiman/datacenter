require 'net/ssh'
require 'open3'

Dir.glob(File.expand_path('datacenter/*.rb', File.dirname(__FILE__))).sort.each { |f| require f }