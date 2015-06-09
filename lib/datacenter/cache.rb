module Datacenter
  class Cache

    def initialize(expiration_time=nil)
      @expiration_time = expiration_time
      @data = {}
    end

    def fetch(key, &block)
      set key, block.call if !data.key?(key) || expired?(key)
      get key
    end

    private

    attr_reader :data, :expiration_time

    def get(key)
      data[key][:value]
    end

    def set(key, value)
      data[key] = {
        value: value,
        fetched_at: Time.now
      }
    end

    def expired?(key)
      return false unless expiration_time
      Time.now >= data[key][:fetched_at] + expiration_time
    end

  end
end