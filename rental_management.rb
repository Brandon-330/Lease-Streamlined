require 'sinatra'
require 'sinatra/contrib' # To implement Sinatra reloader
require 'erubis' # To escape HTML for user input
require 'bcrypt' # Encrypt passwords

require_relative 'database_persistance'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32) # Secures session
  set :erb, :escape_html => true # Escapes user input to prevent Javascript injection
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'database_persistance.rb'
end

helpers do 
  CONTENT_PER_PAGE = 5
  # Create pagination for an array of content
  def paginate(content_array, page_number)
    content_idx = (page_number - 1) * CONTENT_PER_PAGE
    content_array[content_idx, CONTENT_PER_PAGE]
  end

  def load_building(id)
    unless is_integer?(id)
      session[:message] = 'Building was not found'
      redirect '/buildings'
    end

    building = @storage.find_building(id)
    return building if building

    session[:message] = 'Building was not found'
    redirect '/buildings'
  end

  def load_apartments(building_id)
    @storage.find_apartment(building_id)
  end

  def load_page(content_array, page_param)
    page = (page_param || 1).to_i
    if page <= 0 || page > last_page(content_array)
      session[:message] = 'Page does not exist'
      redirect '/buildings'
    else
      page
    end
  end
end

# Last page to be used during pagination
def last_page(content_array)
  page_number = 1
  while page_number * CONTENT_PER_PAGE < content_array.size
    page_number += 1
  end

  page_number
end

def is_integer?(string)
  string.to_i.to_s == string
end

def error_signin?(username, password)
  if username.empty? || password.empty?
    return 'Please enter your username and password'
  end

  result = @storage.find_credentials(username, password)
  if result.size == 0
    return 'User not found'
  end
end

def error_new_building(name)
  if name.nil?
    'Please enter the building name'
  elsif @storage.all_buildings.any? { |building| building[:name] == name }
    'Please enter a unique building name'
  end
end

def error_new_apartment(apartment_number, rent, tenant=nil)
  if error = error_apartment_number(apartment_number)
    error
  elsif error = error_rent(rent)
    error
  elsif @storage.all_tenants.any? { |tenants_hsh| tenants_hsh[:name] == tenant }
    'Tenant is already occupying another appartment'
  end
end

def error_apartment_number(number_str)
  if !is_integer?(number_str)
    'Apartment number must be all integers'
  elsif number_str.length != 3
    'Apartment number must be three digits in length'
  end
end

def error_rent(rent_str)
  return 'Enter an input for rent' if rent_str == ''

  rent_str += '.00' if !rent_str.include?('.')
  rent_arr = rent_str.split('.')
  
  if rent_arr.size != 2
    'Rent must include dollars, a period, and cents'
  elsif rent_arr.any? { |str| str.nil? }
    'Rent must include cents'
  # CONTINUE HERE
  elsif rent_arr.any? { |str| !is_integer?(str.gsub(/^0+/, '')) } # Remove leading zeroes
    'Please enter valid integers for dollars and cents'
  elsif rent_arr[0].to_i <= 0 || rent_arr[0].to_i > 10000
    'Please enter a rent amount greater than $0 and less than $10,000'
  elsif rent_arr[1].to_i < 0 || rent_arr[1].to_i > 99
    'Please enter valid cents between 0 and 99'
  end
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
  @page = load_page(@buildings, params[:page])

  erb :buildings
end

get '/buildings/new' do
  if !signed_in?
    session[:message] = 'You must be signed in to view this page'
    redirect '/users/signin'
  else
    erb :new_building
  end
end

# WORK ON THIS
post '/buildings/new' do
  building_name = params[:name].strip

  if error = error_new_building(building_name)
    session[:message] = error
    erb :new_building
  else
    @storage.add_building(building_name)
    session[:message] = "#{building_name} successfully added"
    redirect '/buildings'
  end
end

get '/buildings/:id' do
  building_id = params[:id]
  @building = load_building(building_id)
  @apartments = load_apartments(building_id)
  @page = load_page(@apartments, params[:page])

  erb :building
end

get '/buildings/:id/edit' do
  if !signed_in?
    session[:message] = 'You must be signed in to view this page'
    redirect '/users/signin'
  end

  building_id = params[:id]
  @building = load_building(building_id)

  erb :edit_building
end

post '/buildings/:id/edit' do
  building_id = params[:id]
  building_name = params[:building_name].strip
  @building = load_building(building_id)

  @storage.update_building(building_id, building_name)
  session[:message] = 'Building was successfully updated'
  redirect "/buildings/#{@building[:id]}"
end

post '/buildings/:id/delete' do
  building_id = params[:id]
  @building = load_building(building_id)

  @storage.delete_building(@building[:id])
  session[:message] = 'Building was successfully deleted'
  redirect '/buildings'
end

post '/buildings/:building_id/apartments/new' do
  building_id = params[:building_id]
  apartment_number = params[:apartment_number].strip
  rent = params[:rent].strip
  tenant = params[:tenant].strip

  @building = load_building(building_id)
  @apartments = load_apartments(building_id)
  @page = load_page(@apartments, params[:page])

  if error = error_new_apartment(apartment_number, rent, tenant)
    session[:message] = error
    erb :building
  else
    session[:message] = 'Apartment successfully added'
    redirect "/buildings/#{@building[:id]}"
  end
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

  if error = error_signin?(username, password)
    session[:message] = error
    erb :signin
  else
    session[:username] = username
    session[:message] = 'Successfully signed in'
    redirect '/buildings'
  end
end

post '/users/signout' do
  session.delete(:username)

  redirect '/buildings'
end

not_found do
  session[:message] = 'That page was not found'
  redirect '/buildings'
end