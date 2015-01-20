#-----------------------------------------------------------------------------#
#   redis.rb                                                                  #
#                                                                             #
#   Copyright (c) 2015, Seventy Four, Inc.                                    #
#   All rights reserved.                                                      #
#-----------------------------------------------------------------------------#



require 'redis'
require 'singleton'
require 'uri'

require './config'



module Singletons
  class Redis
    include Singleton
    attr_accessor :redis

    def self.transaction(&block)
      instance.redis.multi
      yield
    ensure
      multi_bulk_reply = instance.redis.exec
      return multi_bulk_reply unless multi_bulk_reply.nil?
      warn '[REDIS] transaction failed; retrying'
      transaction(&block)
    end

    def self.cache(key, expiry, &block)
      if (value = instance.redis.get(key)).nil?
        instance.redis.set(key, value = yield)
        instance.redis.expire(key, expiry) unless expiry.nil?
      end
      value
    end

    private

    def initialize
      uri = $settings.redis_url || 'http://localhost:6379/'
      uri, options = URI.parse(uri), {}
      %i[host port password].each { |sym| options[sym] = uri.public_send(sym) }
      @redis = ::Redis.new(options)
    end
  end
end
