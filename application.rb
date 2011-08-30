require 'sinatra'
require 'pry'
require 'pathname'
require 'json'
require 'yaml'
require 'haml'
require 'digest/md5'
require './filesystem.rb'

configure do
  Settings = YAML.load_file('config.yaml')
end

get '/' do
  haml :index, :layout => :layout
end

post '/' do
  @api_key = Digest::MD5.hexdigest(Time.now.to_s)
  haml :created
end

get '/directory' do
  
end

get '/archive/*' do
  
end

get '/settings' do
  content_type :json
  {:quota => 80, :diskuse => 40}.to_json
end

put '/settings' do
  
end