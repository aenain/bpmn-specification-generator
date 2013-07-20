require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/content_for'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require 'sinatra/form_helpers'
require 'sinatra/flash'
require 'gon-sinatra'
require 'json'
require 'execjs'

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

  enable :sessions

  register Sinatra::Flash
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
  helpers Sinatra::FormHelpers

  # routing
  get '/' do
    redirect '/models/new'
  end

  get '/models/new' do
    definitions = File.read("./config/rules.yml")
    model_params = { rule_definitions: definitions }.reverse_merge(params[:business_model] || {})
    @model = BusinessModel.new(model_params)

    haml 'models/new'.to_sym
  end

  post '/models' do
    @errors = []
    @notices = []

    # simple params[:business_model][:raw_xml] is not working.
    raw_xml = params[:business_model][:raw_xml]
    @model = BusinessModel.new(params[:business_model].merge(raw_xml: nil))

    if raw_xml.nil? || @model.rule_definitions.empty?
      @errors << "Both XML Model and Rule definitions have to be specified"
    else
      @model.raw_xml = params[:business_model][:raw_xml][:tempfile].read

      begin
        diagram = @model.build_diagram
        diagram.build_graph(@model.raw_xml)

        diagram = @model.build_diagram_with_patterns(graph: diagram.graph)
        diagram.extract_patterns
        diagram.prepare_visualization

        @model.build_logical_specification
      rescue Bpmn::Utilities::PatternExtractor::NotFullyMatched, Bpmn::Specification::MissingSpecification => e
        @notices << e.to_s
      end

      flash.next[:notice] = @notices.join(', ') unless @notices.empty?

      if @model.save
        redirect "/models/#{@model.id}"
      else
        @errors.concat @model.errors.full_messages
      end
    end

    unless @errors.empty?
      flash.now[:error] = @errors.join(', ')
      haml 'models/new'.to_sym
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