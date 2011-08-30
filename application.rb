require 'sinatra'
require 'pry'
require 'pathname'
require 'json'
require './filesystem.rb'

get '/' do
  'Hello World!'
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