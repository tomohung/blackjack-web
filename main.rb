require 'sinatra'
require 'pry'
require './blackjack.rb'

#use Rack::Session::Pool, :expire_after => 2592000
enable :sessions

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

  player = Player.new(session[:username])
  deck = Deck.new(player)
  deck.deal_initial_cards_to_everyone
  session[:deck] = deck

  redirect '/game'
end

get '/game' do

  erb :game
end

get '/hit_or_stay' do
  if params.has_key?("hit")
    deck = session[:deck]
    deck.cards.deal_a_card(deck.players.first)
    redirect '/game'
  end

  if params.has_key?("stay")

  end
end