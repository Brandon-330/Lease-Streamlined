require 'sinatra'
require 'sinatra/reloader'

require_relative 'database_persistance'
also_reload 'database_persistance.rb'

configure do
  enable :sessions
end

helpers do 
  def sort_properties(properties, &block)
    sorted_properties_by_rent = properties.sort_by { |property| property[:rent] }

    sorted_properties_by_rent.each(&block)
  end

  def load_property(id)
    @storage.find_property(id)

    session[:error] = 'Invalid property selected'
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

get '/properties/:id' do
  id = params[:id]
  @property = load_property(id)
end