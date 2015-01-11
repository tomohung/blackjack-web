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

  player = Player.new(params[:username])
  deck = Deck.new(player)
  session[:deck] = deck

  redirect '/bet'
end

post '/set_bet' do  
  
  deck = session[:deck]
  player = deck.player
  redirect '/game' if !deck.game_is_over

  bet = params[:bet].to_i
  redirect '/bet' if bet < 1 # bet must larger than 0
  
  deck.deal_initial_cards_to_everyone
  player.bet = bet
  player.capital -= bet

  redirect '/game'
end

get '/game' do
  erb :game
end

post '/hit' do
  deck = session[:deck]
  deck.player_hit
  redirect '/game'
end

post '/stay' do
  session[:deck].dealer_turn = true
  redirect '/game'
end

post '/ask_dealer' do
  deck = session[:deck]
  deck.asking_dealer_hit_again?

  redirect '/game'
end