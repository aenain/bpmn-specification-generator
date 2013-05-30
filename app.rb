# add lib folder to load path
$: << __dir__ + "/lib"

require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/content_for'

#
# run with: ruby app.rb
# to bind ip: ruby app.rb 127.0.0.1
class App < Sinatra::Base
  set :root, __dir__
  set :bind, ARGV.first if /\A(\d{1,3}\.){3}\d{1,3}\z/ =~ ARGV.first

  register Sinatra::AssetPack
  helpers Sinatra::ContentFor

  assets do
    serve '/javascripts',     from: 'app/javascripts'
    serve '/stylesheets',     from: 'app/stylesheets'
    serve '/images',          from: 'app/images'

    js :all, %w[/javascripts/*.js]
    css :all, %w[/stylesheets/*.css]
  end

  get '/' do
    haml :index
  end

  # start the server
  run!
end
