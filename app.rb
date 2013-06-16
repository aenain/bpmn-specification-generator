require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/content_for'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require 'gon-sinatra'
require 'json'
require 'pry-debugger'

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
  register Sinatra::Twitter::Bootstrap::Assets
  register Gon::Sinatra
  helpers Sinatra::ContentFor

  assets do
    serve '/javascripts',     from: 'app/javascripts'
    serve '/stylesheets',     from: 'app/stylesheets'
    serve '/images',          from: 'app/images'

    js :all, %w[/javascripts/*.js]
    css :all, %w[/stylesheets/*.css]
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  # routing
  get '/' do
    redirect '/models/new'
  end

  get '/models/new' do
    haml 'models/new'.to_sym
  end

  post '/models' do
    @model = BusinessModel.new
    @model.description = params[:business_model][:description]
    @model.raw_xml = params[:business_model][:raw_xml][:tempfile].read

    diagram = @model.build_diagram
    diagram.build_graph(@model.raw_xml)
    diagram.prepare_visualization

    diagram = @model.build_diagram_with_patterns(graph: diagram.graph)
    diagram.extract_patterns
    diagram.prepare_visualization

    if @model.save
      redirect "/models/#{@model.id}"
    else
      # TODO! error handling?
      redirect "/models/new"
    end
  end

  get '/models/:id' do
    @model = BusinessModel.find(params[:id])
    diagram = @model.diagram_with_patterns || @model.diagram
    gon.visualization_data = JSON.parse(diagram.visualization)
    haml 'models/show'.to_sym
  end

  # start the server only if it has been called as $ ruby app.rb
  run! if app_file == $0
end