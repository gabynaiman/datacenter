require 'minitest_helper'

describe Datacenter::Cache do
  
  it 'Without expiration' do
    cache = Datacenter::Cache.new
    i = 0
    3.times do 
      cache.fetch(:key_1) { i += 1 }.must_equal 1
    end
  end

  it 'Cached key' do
    cache = Datacenter::Cache.new 1000
    i = 0
    3.times do 
      cache.fetch(:key_1) { i += 1 }.must_equal 1
    end
  end

  it 'Expired key' do
    cache = Datacenter::Cache.new 0
    i = 0
    1.upto(3) do |n|
      cache.fetch(:key_1) { i += 1 }.must_equal n
    end
  end

end