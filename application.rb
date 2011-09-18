require 'sinatra'
require 'sinatra/reloader'
require 'pathname'
require 'json'
require 'yaml'
require 'haml'
require 'digest/md5'
require 'shellwords'
require './lib.rb'
require './filesystem.rb'

configure do |c|
  # Auto reloading for updates
  c.also_reload "*.rb"
  c.also_reload "config.yaml"
  begin
    Settings = YAML.load_file('config.yaml')
    Settings['version'] = '0.0.0'
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
    'api_key' => Digest::MD5.hexdigest(Time.now.to_s + rand.to_s),
    'directory' => params[:directory].strip,
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
    @recursive = params[:recursive] || false
    @how_many = params[:limit]
    
    f = @files.all(@recursive)
    f = f.first(@how_many.to_i) if @how_many
    
    {
      :files => f
    }.to_json
  rescue Exception => e
    forward_error(e)
  end
end

get '/archive' do
  require_api_key
  content_type :json
  
  @files = Filesystem.new(Settings['directory'])
  @files = @files.subdir(params[:path])
    
  begin
    return @files.to_zip.to_json
  rescue Exception => e
    forward_error e
  end
end

get '/settings' do
  require_api_key
  content_type :json
  s = Settings.dup
  s.delete('api_key')
  s.to_json
end

put '/settings' do
  require_api_key
  
end

post '/update' do
  require_api_key
  here = File.expand_path(File.dirname(__FILE__))
  `cd #{here} && git pull`
end