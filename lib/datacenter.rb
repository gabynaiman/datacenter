require 'net/ssh'

Dir.glob(File.expand_path('datacenter/*.rb', File.dirname(__FILE__))).sort.each { |f| require f }