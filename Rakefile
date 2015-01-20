#-----------------------------------------------------------------------------#
#   Rakefile                                                                  #
#                                                                             #
#   Copyright (c) 2015, Seventy Four, Inc.                                    #
#   All rights reserved.                                                      #
#-----------------------------------------------------------------------------#



require './config'
require './singletons/redis'



namespace :assets do
  redis = Singletons::Redis.instance.redis

  desc 'Precompile Sprockets'
  task :precompile_sprockets do
    print 'Precompiling Sprockets... '
    $settings.assets.each do |path|
      dir, file, expiry = path.split('/') << $settings.asset_expiry
      redis.set(path, $settings.sprockets[file].to_s)
      redis.expire(path, expiry) unless expiry.nil?
    end
    puts 'done.'
  end

  desc 'Precompile assets'
  task precompile: :precompile_sprockets
end



desc 'Run tests'
task :default do
end
