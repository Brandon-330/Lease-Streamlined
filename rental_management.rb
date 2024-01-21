require 'sinatra'
require 'sinatra/reloader'

require_relative 'database_persistance'

configure do
  enable :sessions
end

before do
  @storage = Database.new
end

get '/' do
  redirect '/rentals'
end

get '/rentals' do
  @rental_apartments = @storage.all_apartments
  erb :rentals
end