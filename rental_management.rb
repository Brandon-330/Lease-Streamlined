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
    return nil if id.to_i.to_s != id
    @storage.find_building(id)
  end

  def load_apartments(building_id)
    @storage.find_apartments(building_id)
  end

  def display_form_input(label_text, for_attribute)
    <<~FORM
    <div>
      <label for=#{for_attribute}>#{label_text}
        <input name='#{for_attribute}' value='#{params[for_attribute.to_sym]}'></input>
      </label>
    </div>
    FORM
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

def redirect_homepage(message)
  session[:message] = message
  redirect '/'
end

def signed_in?
  session[:username]
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

# WORK ON THESE
get '/buildings/new' do
  redirect_homepage('You must be signed in to view this page') unless signed_in?
  erb :new_building
end

post '/buildings/new' do
end

# WORK ON THIS
get '/buildings/:id' do
  building_id = params[:id]
  @building = load_building(building_id)
  
  if @building.nil?
    redirect_homepage('Building was not found')
  end

  @apartments = load_apartments(building_id)
  erb :building
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
    erb :signin
  else
    session[:username] = username
    redirect_homepage('Successfully signed in!')
  end
end

post '/users/signout' do
  session.delete(:username)

  redirect '/'
end

not_found do
  redirect_homepage('That page was not found')
end