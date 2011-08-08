require 'sinatra'

configure do
  require 'redis'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  # REDIS = Redis.new
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end



helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def random_string(length)
    rand(36**length).to_s(36)
  end
end

get '/' do
  erb :index
end

post '/' do
  if params[:url] and not params[:url].empty?
    @shortcode = random_string 5
    REDIS.setnx "links:#{@shortcode}", params[:url]
  end
  erb :index
end

get '/:shortcode' do
  @url = REDIS.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end