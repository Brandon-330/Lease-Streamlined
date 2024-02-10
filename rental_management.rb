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

  def check_signed_in
    unless session[:username]
      session[:message] = 'You must be signed in to view this page'
      redirect '/users/signin'
    end
  end

  def load_building(id)
    # if id is not an integer, execute this block
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
    # building_id parameter has already sanitized input earlier
    @storage.all_apartments(building_id)
  end

  def load_apartment(building_id, apartment_id)
    # building_id parameter has already sanitized input, if apartment_id is not an integer execute
    unless is_integer?(apartment_id)
      session[:message] = 'Apartment was not found'
      redirect "/buildings/#{building_id}"
    end

    apartment = @storage.find_apartment(building_id, apartment_id)
    return apartment if apartment

    session[:message] = 'Apartment was not found'
    redirect "/buildings/#{building_id}"
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
  /^[0-9]+$/.match?(string) # String must be or or more number characters at the beginning and end
end

def error_signin(username, password)
  if username.empty? || password.empty?
    return 'Please enter your username and password'
  end

  result = @storage.find_credentials(username)
  if result.nil?
    return 'User not found'
  elsif BCrypt::Password.new(result[:password]) != password
    return 'Invalid credentials'
  end
end

def error_new_building(name)
  if name.empty?
    'Please enter the building name'
  elsif @storage.all_buildings.any? { |building| building[:name] == name }
    'Please enter a unique building name'
  end
end

def error_new_apartment(building_id, apartment_number, rent, tenant=nil)  
  if error = error_apartment_number(apartment_number)
    error
  elsif load_apartments(building_id).any? { |apartment| apartment[:number] == apartment_number }
    'Apartment number is already taken'
  elsif error = error_rent(rent)
    error
  elsif error = error_tenant(tenant)
    error
  elsif @storage.all_apartments(building_id).any? { |apartment| apartment[:tenant_name] == tenant }
    'Tenant is already occupying an apartment'
  end
end

def error_update_apartment(apartment_hsh, apartment_number, rent, tenant=nil)
  building_id = apartment_hsh[:building_id]
  apartment_id = apartment_hsh[:id]

  if apartment_hsh[:number] == apartment_number && apartment_hsh[:rent] == rent && apartment_hsh[:tenant_name] == tenant
    'No changes has been made'
  elsif error = error_apartment_number(apartment_number)
    error
  # Accept same apartment number as before
  elsif load_apartments(building_id).reject { |iterating_apartment| iterating_apartment[:id] == apartment_hsh[:id] }.any? { |iterating_apartment| iterating_apartment[:number] == apartment_number }
    'Apartment number is already taken'
  elsif error = error_rent(rent)
    error
  elsif error = error_tenant(tenant)
    error
  # Something awfully wrong is going on here
  elsif @storage.all_apartments(building_id).reject { |iterating_apartment| iterating_apartment[:id] == apartment_hsh[:id] }.any? { |iterating_apartment| iterating_apartment[:tenant_name] == tenant }
    'Tenant is already occupying an apartment'
  end
end

def error_apartment_number(number_str)
  if number_str.empty?
    'Apartment number cannot be empty'
  elsif !is_integer?(number_str)
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
  elsif rent_arr[0].empty?
    'Rent cannot be empty'
  elsif rent_arr.any? { |str| !is_integer?(str) }
    'Please enter valid integers for dollars and cents'
  elsif rent_arr[0].to_i <= 0 || rent_arr[0].to_i > 10000
    'Please enter a rent amount greater than $0 and less than $10,000'
  elsif rent_arr[1].to_i < 0 || rent_arr[1].to_i > 99
    'Please enter valid cents between 0 and 99'
  end
end

def error_tenant(tenant_str)
  'Invalid tenant name' if /[0-9]/.match?(tenant_str)
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
  check_signed_in
  
  erb :new_building
end

# WORK ON THIS
post '/buildings/new' do
  building_name = params[:name].strip.split.map(&:capitalize).join(' ')

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
  check_signed_in

  building_id = params[:id]
  @building = load_building(building_id)
  @apartments = load_apartments(@building[:id])
  @page = load_page(@apartments, params[:page])

  erb :building
end

post '/buildings/:id' do
  building_id = params[:id]
  apartment_number = params[:apartment_number].strip
  rent = params[:rent].strip
  tenant = params[:tenant].strip.capitalize

  @building = load_building(building_id)
  @apartments = load_apartments(@building[:id])
  @page = load_page(@apartments, params[:page])

  if error = error_new_apartment(@building[:id], apartment_number, rent, tenant)
    session[:message] = error
    erb :building
  else
    @storage.add_apartment(@building[:id], apartment_number, rent, tenant)
    session[:message] = 'Apartment successfully added'
    redirect "/buildings/#{@building[:id]}"
  end
end

get '/buildings/:id/edit' do
  check_signed_in

  building_id = params[:id]
  @building = load_building(building_id)

  erb :edit_building
end

post '/buildings/:id/edit' do
  building_id = params[:id]
  building_name = params[:name].strip.split.map(&:capitalize).join(' ')
  @building = load_building(building_id)

  if @building[:name] == building_name
    session[:message] = 'No changes made'
    erb :edit_building
  else
    @storage.update_building(@building[:id], building_name)
    session[:message] = 'Building was successfully updated'
    redirect "/buildings/#{@building[:id]}"
  end
end

post '/buildings/:id/evict_tenants' do
  building_id = params[:id]
  @building = load_building(building_id)

  @storage.evict_all_tenants(@building[:id])
  session[:message] = "All tenants in #{@building[:name]} have been evicted"
  redirect "/buildings/#{@building[:id]}"
end

post '/buildings/:id/delete' do
  building_id = params[:id]
  @building = load_building(building_id)

  @storage.delete_building(@building[:id])
  session[:message] = 'Building was successfully deleted'
  redirect '/buildings'
end

get '/buildings/:building_id/apartments/:apartment_id/edit' do
  check_signed_in

  building_id = params[:building_id]
  apartment_id = params[:apartment_id]
  @building = load_building(building_id)
  @apartment = load_apartment(@building[:id], apartment_id)

  erb :edit_apartment
end

post '/buildings/:building_id/apartments/:apartment_id/edit' do
  building_id = params[:building_id]
  apartment_id = params[:apartment_id]
  @building = load_building(building_id)
  @apartment = load_apartment(@building[:id], apartment_id)

  apartment_number = params[:number].strip
  rent = params[:rent].strip
  tenant_name = params[:tenant_name].strip.capitalize

  if error = error_update_apartment(@apartment, apartment_number, rent, tenant_name)
    session[:message] = error
    erb :edit_apartment
  else
    @storage.update_apartment(@apartment, apartment_number, rent, tenant_name)
    session[:message] = 'Apartment was successfully updated'
    redirect "/buildings/#{@building[:id]}"
  end
end

post '/buildings/:building_id/apartments/:apartment_id/delete' do
  building_id = params[:building_id]
  apartment_id = params[:apartment_id]
  @building = load_building(building_id)
  @apartment = load_apartment(@building[:id], apartment_id)

  @storage.delete_apartment(@apartment)
  session[:message] = 'Apartment was successfully deleted'
  redirect "/buildings/#{@building[:id]}"
end

get '/users/signin' do
  if session[:username]
    session[:message] = 'Already logged in'
    redirect '/buildings'
  elsif @storage.all_usernames.empty?
    redirect '/users/signup'
  else
    erb :signin
  end
end

post '/users/signin' do
  username = params[:username].strip
  password = params[:password].strip

  if error = error_signin(username, password)
    session[:message] = error
    erb :signin
  else
    session[:username] = username
    session[:message] = 'Successfully signed in'
    redirect '/buildings'
  end
end

get '/users/signup' do
  if @storage.all_usernames.empty?
    session[:message] = 'Select initial admin username and password'
  else
    check_signed_in
  end
  
  erb :signup
end

post '/users/signup' do
  username = params[:username]
  password = params[:password]

  if username.empty? || password.empty?
    session[:message] = 'Please enter a valid username and password'
    erb :signup
  elsif username.include?(' ') || password.include?(' ')
    session[:message] = 'Please do not include spaces in username/password'
    erb :signup
  elsif @storage.all_usernames.any? { |account| account[:username] == username  }
    session[:message] = 'Username already taken'
    erb :signup
  else
    @storage.add_credentials(username, BCrypt::Password.create(password))
    session[:message] = 'Account successfully created'
    redirect '/users/signin'
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