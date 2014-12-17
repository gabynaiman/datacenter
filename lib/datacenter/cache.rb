module Datacenter
  class Cache

    def initialize(expiration_time=nil)
      @expiration_time = expiration_time
      @data = {}
    end

    def fetch(key, &block)
      set key, &block if !key?(key) || expired?(key)
      get key
    end

    private

    def get(key)
      @data[key][:value]
    end

    def set(key, &block)
      @data[key] = {
        value: block.call,
        fetched_at: Time.now
      }
    end

    def key?(key)
      @data.key? key
    end

    def expired?(key)
      return false unless @expiration_time
      Time.now > @data[key][:fetched_at] + @expiration_time
    end

  end
end