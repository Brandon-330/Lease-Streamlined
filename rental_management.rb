require 'sinatra'
require 'sinatra/reloader'

require_relative 'database_persistance'
also_reload 'database_persistance.rb'

configure do
  enable :sessions
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
  username = params[:username]
  password = params[:password]

  if username == 'admin' && password == 'secret'
    session[:username] = username
    redirect '/'
  else
    session[:message] = 'Invalid credentials'
    status 422
    erb :signin
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