require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/content_for'
require 'sinatra/activerecord'

# add to the load path
MODELS_PATH = File.join('app', 'models')
$: << File.join(__dir__, MODELS_PATH)
$: << File.join(__dir__, 'lib')

# require all models
Dir.glob(File.join('.', MODELS_PATH, '*.rb')) { |model| require model }

# run with: ruby app.rb
# to bind ip: ruby app.rb 127.0.0.1
class App < Sinatra::Base
  set :root, __dir__
  set :bind, ARGV.first if /\A(\d{1,3}\.){3}\d{1,3}\z/ =~ ARGV.first

  register Sinatra::AssetPack
  register Sinatra::ActiveRecordExtension
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

  # start the server only if it has been called as $ ruby app.rb
  run! if app_file == $0
end