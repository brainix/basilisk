#-----------------------------------------------------------------------------#
#   config.rb                                                                 #
#                                                                             #
#   Copyright (c) 2015, Seventy Four, Inc.                                    #
#   All rights reserved.                                                      #
#-----------------------------------------------------------------------------#



require 'active_support/all'
require 'closure-compiler'
require 'haml'
require 'sinatra'
require 'sprockets'
require 'yui/compressor'



configure do
  # Web framework
  $settings = settings
  GC::Profiler.enable
  set :worker_processes, 3
  set :worker_min_threads, 1
  set :worker_max_threads, 1
  set :haml, options = { format: :html5, ugly: true }
  options.each { |key, value| Haml::Options.defaults[key] = value }
  enable :logging
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  set :static_cache_control, [:public, max_age: 1.year.to_i]

  # Assets
  set :sprockets, Sprockets::Environment.new
  settings.sprockets.css_compressor = YUI::CssCompressor.new
  opts = { compilation_level: 'ADVANCED_OPTIMIZATIONS' }
  settings.sprockets.js_compressor = Closure::Compiler.new(opts)
  dirs, files = Dir.entries(File.join(settings.root, 'app')), []
  dirs.reject { |e| e[0] == '.' }.each do |dir|
    settings.sprockets.append_path("app/#{dir}")
    files += Dir.entries("app/#{dir}").reject! { |e| e[0] == '.' }.map! do |e|
      "#{dir}/#{e}".gsub('.sass', '.css').gsub('.coffee', '.js')
    end
  end
  set :assets, files

  # Redis and Memcached
  set :redis_url, ENV['REDISCLOUD_URL']
end



configure :production do
  require 'newrelic_rpm'

  set :log_level, :info
  set :asset_expiry, nil          # Expiration for the Redis cached resource
  set :asset_expires, 1.week.to_i # Expiration for the HTTP Expires header
end



configure :development do
  require 'find'
  require 'sinatra/reloader'
  Find.find('.') do |path|
    Find.prune if path.start_with?('./.')
    also_reload(path) if path.end_with?(*%w[.rb .yml])
  end

  $stdout.sync = true

  set :log_level, :debug
  set :asset_expiry, 1.second.to_i  # Expiration for the Redis cached resource
  set :asset_expires, 1.minute.to_i # Expiration for the HTTP Expires header
end
