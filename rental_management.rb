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
  CONTENT_PER_PAGE = 5
  STATES = ['AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY']
  def paginate(content_array, page_number)
    content_idx = (page_number - 1) * CONTENT_PER_PAGE
    content_array[content_idx, CONTENT_PER_PAGE]
  end

  def format_address(building_hash)
    hsh = building_hash
    "#{hsh[:building_number]} #{hsh[:street]}, #{hsh[:city]}, #{hsh[:state]} #{hsh[:zip_code]}"
  end

  def load_building(id)
    return nil if id.to_i.to_s != id
    @storage.find_building(id)
  end

  def load_apartments(building_id)
    @storage.find_apartments(building_id)
  end

  def display_form_input(label_text, for_attribute, value_attribute='')
    <<~FORM
    <div>
      <label for=#{for_attribute}>#{label_text}
        <input name='#{for_attribute}' value='#{value_attribute}'></input>
      </label>
    </div>
    FORM
  end
end

def last_page(content_array)
  page_number = 1
  while page_number * CONTENT_PER_PAGE < content_array.size
    page_number += 1
  end

  page_number
end

def error_for_page(content_array, page)
  'Page does not exist' if page <= 0 || page > last_page(content_array)
end

def error_for_signin?(username, password)
  if username.empty? || password.empty?
    return 'Please enter your username and password'
  end

  result = @storage.find_credentials(username, password)
  if result.size == 0
    return 'User not found'
  end
end

def error_new_building(name, *address)

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
  @page = (params[:page] || 1).to_i
  @buildings = @storage.all_buildings

  if error = error_for_page(@buildings, @page)
    session[:message] = error
    redirect '/buildings'
  elsif !signed_in?
    session[:message] = 'User must be signed in to view this page'
    redirect '/users/signin'
  else
    erb :buildings
  end
end

# WORK ON THESE
get '/buildings/new' do
  redirect_homepage('You must be signed in to view this page') unless signed_in?
  
  erb :new_building
end

# WORK ON THIS
post '/buildings/new' do
  building_name = params[:name].strip
  number = params[:number].strip
  street = params[:street].strip
  city = params[:city].strip
  state = params[:state].strip
  zip = params[:zip].strip

  if error = error_new_building(building_name, number, street, city, state, zip)
  else
    redirect_homepage("#{building_name} successfully added")
  end
end

get '/buildings/:id' do
  building_id = params[:id]
  @building = load_building(building_id)
  
  if @building.nil?
    redirect_homepage('Building was not found')
  end

  @apartments = load_apartments(building_id)
  erb :building
end

get '/buildings/:id/edit' do
  building_id = params[:id]
  @building = load_building(building_id)

  if @building.nil?
    redirect_homepage('Building was not found')
  end

  erb :edit_building
end

post '/buildings/:id/edit' do
  building_id = params[:id]
  @building = load_building(building_id)

  if @building.nil?
    redirect_homepage('Building was not found')
  end

  building_name = params[:building_name].strip
  number = params[:building_number].strip
  street = params[:street].strip
  city = params[:city].strip
  state = params[:state].strip
  zip = params[:zip_code].strip

  @storage.update_building_name(building_id, building_name)
  
  redirect_homepage('Building was successsfully updated')
  erb :edit_building
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