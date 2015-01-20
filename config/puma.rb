#-----------------------------------------------------------------------------#
#   puma.rb                                                                   #
#                                                                             #
#   Copyright (c) 2015, Seventy Four, Inc.                                    #
#   All rights reserved.                                                      #
#-----------------------------------------------------------------------------#



require './config'
require './singletons/redis'



workers $settings.worker_processes
threads $settings.worker_min_threads, $settings.worker_max_threads
preload_app!
# rackup DefaultRackup
port ENV['PORT']
environment $settings.environment.to_s



on_worker_boot do
  Singletons::Redis.instance.redis.quit

  uri, options = URI.parse($settings.redis_url), {}
  %i[host port password].each { |sym| options[sym] = uri.public_send(sym) }
  Singletons::Redis.instance.redis = Redis.new(options)
end
