require 'sinatra'
require 'pry'
require 'pathname'
require 'json'
require 'yaml'
require 'haml'
require 'digest/md5'
require './filesystem.rb'
require './lib.rb'

configure do
  begin
    Settings = YAML.load_file('config.yaml')
  rescue Errno::ENOENT
    Settings = nil
  end
end

get '/' do
  require_fresh_user
  
  @default_dir = File.dirname(__FILE__)
  
  haml :index, :layout => :layout
end

post '/' do
  require_fresh_user
  
  Settings = {
    'api_key' => Digest::MD5.hexdigest(Time.now.to_s),
    'directory' => params[:directory],
    'follow_symlinks' => true
  }
  Settings['follow_symlinks'] = false unless params[:follow_symlinks]
  
  # Write the config file
  @error = nil
  begin
    File.open( 'config.yaml', 'w' ) do |out|
      YAML.dump( Settings, out )
    end
  rescue Exception => e
    @error = e
  end
  
  haml :created
end

get '/directory' do
  require_api_key
  content_type :json
  
  begin
    @files = Filesystem.new(Settings['directory'])
    @files = @files.subdir(params[:subdir]) if params[:subdir]
    return @files.all.to_json
  rescue Exception
    halt 404
  end
end

get '/archive/*' do
  
end

get '/settings' do
  require_api_key
  content_type :json
  Settings.delete('api_key')
  Settings.to_json
end

put '/settings' do
  
end