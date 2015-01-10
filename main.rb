require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  redirect '/login'
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
  session[:capital] = 500
  redirect '/bet'
end

post '/set_bet' do  
  redirect '/bet' if params[:bet].to_i < 1
  session[:bet] = params[:bet].to_i
  session[:capital] -= params[:bet].to_i
  redirect '/game'
end

get '/game' do
  erb :game
end