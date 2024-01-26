require 'sinatra'
require 'sinatra/contrib'
require 'bcrypt'

require_relative 'database_persistance'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => true #Escapes user input to prevent Javascript injection
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'database_persistance.rb'
end

helpers do 
  # WORK ON THIS HELPER METHOD
  def sort_properties(properties, &block)
    sorted_properties_by_rent = properties.sort { |property| property[:name] }

    sorted_properties_by_rent.each(&block)
  end

  def load_property(id)
    @storage.find_property(id)
  end
end

# WORK ON THIS SIGNIN
def error_for_signin?(username, password)
  if username.empty? || password.empty?
    return 'Please enter your username and password'
  end

  result = @storage.find_credentials(username, password)
  if result.size == 0
    return 'User not found'
  end
end

before do
  @storage = Database.new
end

get '/' do
  redirect '/properties'
end

get '/properties' do
  @properties = @storage.all_properties
  erb :properties
end

get '/users/signin' do
  erb :signin
end

# ENCRYPT PASSWORD
post '/users/signin' do
  username = params[:username].strip
  password = params[:password].strip

  if error = error_for_signin?(username, password)
    session[:message] = error
    status 422
    erb :signin
  else
    session[:username] = username
    session[:message] = 'Successfully signed in!'
    redirect '/'
  end
end

post '/users/signout' do
  session.delete(:username)

  redirect '/'
end

# WORK ON THIS
get '/properties/:id' do
  id = params[:id]
  @property = load_property(id)
  erb :property
end

not_found do
  session[:message] = 'That page was not found'
  redirect '/'
end