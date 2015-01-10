require 'sinatra'
require 'pry'

get '/' do
  redirect '/login' if session[:username].nil?
  redirect '/bet'
end

get '/login' do
  erb :login
end

get '/bet' do
  erb :bet
end

post '/set_name' do
  redirect '/login' if params[:username].empty?
  session[:username] = params[:username]
  redirect '/bet'
end