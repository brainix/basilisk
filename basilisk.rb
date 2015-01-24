#-----------------------------------------------------------------------------#
#   basilisk.rb                                                               #
#                                                                             #
#   Copyright (c) 2015, Seventy Four, Inc.                                    #
#   All rights reserved.                                                      #
#-----------------------------------------------------------------------------#



require 'addressable/uri'
require 'net/http'
require 'octokit'

require './config'
require './singletons/redis'
require './tools'



helpers do
  def singleton
    Tools::Ruby.common(%i[redis], __callee__)
    instance = Singletons.const_get(__callee__.to_s.titlecase).instance
    instance.public_send(__callee__)
  end

  %i[redis].each { |callee| alias_method(callee, :singleton) }

  def state
    redis.set(key = (0...8).map { (97 + rand(26)).chr }.join, nil)
    redis.expire(key, 1.minute.to_i)
    key
  end

  def state?
    redis.del(request[:state]) != 0
  end

  Octokit.auto_paginate = true

  def octokit(access_token)
    o = Octokit::Client.new(access_token: access_token)
    o.auto_paginate = true
    o
  end

  def authenticated?
    !session[:access_token].nil?
  end

  def authorized?
    o = octokit(ENV['GITHUB_ACCESS_TOKEN'])
    collabs = o.collabs('brainix/basilisk').map { |user| user.login }
    o = octokit(session[:access_token])
    collabs.include?(o.user.login)
  end

  def user
    octokit(session[:access_token]).user if authenticated?
  end
end



get '/:directory/:file' do
  key, expiry = "#{params[:directory]}/#{params[:file]}", $settings.asset_expiry
  pass unless $settings.assets.include?(key)
  content_types = {
    'stylesheets' => 'text/css',
    'javascripts' => 'application/javascript',
  }
  content_type content_types[params[:directory]]
  my_body = Singletons::Redis.cache(key, expiry) do
    $settings.sprockets[params[:file]].to_s
  end
  expires $settings.asset_expires, :public, :must_revalidate
  etag Digest::SHA1.hexdigest(my_body)
  my_body
end

get '/' do
  haml :index, locals: { title: 'Home', user: user }
end

get '/login' do
  uri = Addressable::URI.parse('https://github.com/login/oauth/authorize')
  uri.query_values = { client_id: ENV['GITHUB_CLIENT_ID'], state: state }
  redirect uri.to_s, 302
end

get '/redirect' do
  halt 401 unless state?
  http = Net::HTTP.new((uri = URI.parse('https://github.com')).host, uri.port)
  http.use_ssl, http.verify_mode = true, OpenSSL::SSL::VERIFY_NONE
  req = Net::HTTP::Post.new('/login/oauth/access_token')
  req['Accept'] = 'application/json'
  req.set_form_data({
    client_id: ENV['GITHUB_CLIENT_ID'],
    client_secret: ENV['GITHUB_CLIENT_SECRET'],
    code: request[:code],
  })
  session[:access_token] = JSON.parse(http.request(req).body)['access_token']
  redirect '/invite', 302
end

get '/invite' do
  halt 401 unless authenticated?
  halt 403 unless authorized?
  o = octokit(session[:access_token])
  locals = {
    title: 'Invite',
    user: user,
    following: Octokit.following(o.user.login),
  }
  haml :invite, locals: locals
end

post '/invite' do
  halt 401, { message: 'unauthorized' }.to_json unless authenticated?
  halt 403, { message: 'forbidden' }.to_json unless authorized?
  o = octokit(session[:access_token])
  following = Octokit.following(o.user.login).map { |user| user.login }
  users = request[:users] || []
  halt 403, { message: 'forbidden' }.to_json unless (users - following).empty?
  o = octokit(ENV['GITHUB_ACCESS_TOKEN'])
  users.each { |user| o.add_collab('brainix/basilisk', user) }
  { users: users }.to_json
end

get '/logout' do
  session.clear
  redirect '/', 302
end

[400..417, 500..505].each do |status_codes|
  status_codes.each do |status_code|
    error status_code do
      locals = { title: status_code }
      locals[:description] = {
        400 => 'Bad Request',
        401 => 'Unauthorized',
        402 => 'Payment Required',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        406 => 'Not Acceptable',
        407 => 'Proxy Authentication Required',
        408 => 'Request Timeout',
        409 => 'Conflict',
        410 => 'Gone',
        411 => 'Length Required',
        412 => 'Precondition Failed',
        413 => 'Request Entity Too Large',
        414 => 'Request-URI Too Long',
        415 => 'Unsupported Media Type',
        416 => 'Requested Range Not Satisfiable',
        417 => 'Expectation Failed',
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Timeout',
        505 => 'HTTP Version Not Supported',
      }[status_code]
      haml :error, locals: locals
    end
  end
end
