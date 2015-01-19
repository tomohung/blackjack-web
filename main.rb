require 'sinatra'
require 'pry'
require './blackjack.rb'

#use Rack::Session::Pool, :expire_after => 2592000
#enable :sessions
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'tealeafweek3' 


helpers do 
  def output_message_if_game_over
    deck = session[:deck]
    return false unless deck.game_is_over

    player = deck.player
    if player.status == BlackJackRuler::STATUS[:win] 
      @winner = "#{player.name} , you win!"
    elsif player.status == BlackJackRuler::STATUS[:tie]
      @winner = "#{player.name}, it's a tie."
    elsif player.status == BlackJackRuler::STATUS[:lose]
      @loser = "Oops! #{player.name}, you are loser..."
    end
    true
  end
end

get '/' do
  erb :login
end

get '/bet' do
  erb :bet
end

post '/set_name' do
  if params[:username].empty?
    @error = "Invalid name!!"
    halt erb(:login)
  end

  player = Player.new(params[:username])
  deck = Deck.new(player)
  session[:deck] = deck

  redirect '/bet'
end

post '/set_bet' do  
  bet = params[:bet].to_i
  deck = session[:deck]
  player = deck.player

  if bet < 1 || bet > player.capital
    @error = "Invalid bet number!!"
    halt erb(:bet)
  end

  if !deck.game_is_over
    halt erb(:game)
  end
  
  deck.deal_initial_cards_to_everyone
  player.bet = bet
  player.capital -= bet

  redirect '/game'
end

get '/game' do
  output_message_if_game_over
  erb :game
end

post '/hit' do
  deck = session[:deck]
  deck.player_hit
  output_message_if_game_over
  erb :game, layout: false
end

post '/stay' do
  session[:deck].dealer_turn = true
  output_message_if_game_over
  erb :game, layout: false
end

post '/ask_dealer' do
  deck = session[:deck]
  deck.asking_dealer_hit_again?
  output_message_if_game_over
  erb :game, layout: false
end