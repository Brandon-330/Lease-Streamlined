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
  def load_building(id)
    @storage.find_building(id)
  end

  def load_apartments(building_id)
    @storage.find_apartments(building_id)
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
  @storage = Database.new(logger)
end

get '/' do
  redirect '/buildings'
end

get '/buildings' do
  @buildings = @storage.all_buildings
  erb :buildings
end

get '/users/signin' do
  erb :signin
end

get '/users/signup' do
  erb :signup
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
get '/buildings/:id' do
  building_id = params[:id]
  @building = load_building(building_id)
  @apartments = load_apartments(building_id)
  erb :building
end

not_found do
  session[:message] = 'That page was not found'
  redirect '/'
end