module BlackJackRuler
  CARDS = { 
    "ace" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7,
    "8" => 8, "9" => 9, "10" => 10, "jack" => 10, "queen" => 10, "king" => 10
    }.freeze

  SUITES = [ "clubs", "diamonds", "hearts", "spades"].freeze
  BLACKJACK = 21.freeze

  STATUS = {win: "WIN", lose: "LOSE", tie: "TIE", unknown: ""}  
end

class Player
  attr_accessor :cards, :status, :capital, :bet
  attr_reader :name

  def initialize(name)
    @name = name
    @status = BlackJackRuler::STATUS[:unknown]
    @cards = []
    @capital = 1000
    @bet = 0
  end

  def get_score
    value = 0
    cards.each {|card| value += BlackJackRuler::CARDS[card[1]]}
    has_ace_card = !cards.select {|card| card[1] == "ace"}.empty?
    return value unless has_ace_card
    value + 10 > BlackJackRuler::BLACKJACK ? value : value + 10
  end

  def blackjack?
    score = get_score
    score == BlackJackRuler::BLACKJACK
  end

  def busted?
    get_score > BlackJackRuler::BLACKJACK
  end

  def reset
    @cards.clear
    @status = BlackJackRuler::STATUS[:unknown]
    @bet = 0
  end

  def hit?
    return false if busted? || blackjack?
    print "#{name}: Hit or Stay (y/n):"
    gets.chomp.downcase == 'y'
  end

  def get_a_card(card)
    @cards << card
  end

  def cards_to_filenames
    filenames = []
    cards.each do |card|
      filename = card[0] + "_" + card[1] + ".jpg"
      filenames << filename
    end
    filenames
  end

end

class RobotPlayer < Player
  def hit?
    return false if busted? || blackjack?
    
    print "#{name} is Thinking."
    2.times do
      sleep 1
      print "."
    end
    puts ""

    get_score < 17
  end
end

class Dealer < RobotPlayer
  attr_accessor :player

  def initialize(name, player)
    super(name)
    @player = player
  end

  def hit?
    return false if busted? || blackjack?
    return true if get_score < 17

    result = false
    if player.status == BlackJackRuler::STATUS[:unknown] &&
      get_score < player.get_score
      result = true
    end    
    result
  end
end

class Cards
  attr_reader :cards

  def initialize(poker_count = 1)
    @cards = []
    poker_count.times do 
      BlackJackRuler::SUITES.each do |suite|
        BlackJackRuler::CARDS.keys.each do |card|
          @cards.push([suite, card])
        end
      end
    end
    @cards.shuffle!
  end

  def deal_a_card(player)
    player.get_a_card(cards.pop)
  end
end

class Deck
  attr_accessor :dealer, :player, :cards, :dealer_turn, :game_is_over
  def initialize(player)
    @player = player
    @dealer = Dealer.new("Dealer", player)
    @cards = Cards.new
    @game_is_over = true
    @dealer_turn = false
  end

  def reset
    dealer.reset
    @cards = Cards.new
    player.reset
    @game_is_over = false
    @dealer_turn = false
  end

  def deal_initial_cards_to_everyone
    reset
    2.times do 
      cards.deal_a_card(player)
      cards.deal_a_card(dealer)
    end
    check_status
  end

  def player_hit
    cards.deal_a_card(player)
    check_status
  end

  def asking_dealer_hit_again?
    cards.deal_a_card(dealer) if dealer.hit?
    check_status
  end

  def check_status
    player.status = BlackJackRuler::STATUS[:win] if player.blackjack?
    player.status = BlackJackRuler::STATUS[:lose] if player.busted?
    
    if dealer_turn
      player.status = BlackJackRuler::STATUS[:lose] if dealer.blackjack?
      player.status = BlackJackRuler::STATUS[:win] if dealer.busted?
    end

    return if stop_game_if_blackjack_or_busted?
    compare_dealer_and_player
  end

  def stop_game_if_blackjack_or_busted?
    if player.blackjack? ||
      player.busted? ||
      dealer.busted?
      @game_is_over = true
      refund
    end
    false
  end

  def compare_dealer_and_player
    if dealer_turn
      if player.get_score < dealer.get_score
        player.status = BlackJackRuler::STATUS[:lose]
        @game_is_over = true
      end
      
      if !dealer.hit? && player.get_score == dealer.get_score
        player.status = BlackJackRuler::STATUS[:tie] 
        @game_is_over = true
      end
      refund
    end
  end

  def refund
    if game_is_over
      case player.status
      when BlackJackRuler::STATUS[:win]
        player.capital += 2 * player.bet
      when BlackJackRuler::STATUS[:tie]
        player.capital += player.bet
      end
    end 
  end
end
