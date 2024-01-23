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
  end
end

before do
  @storage = Database.new
end

get '/' do
  redirect '/properties'
end

get '/properties' do
  @rental_properties = @storage.all_properties
  erb :properties
end