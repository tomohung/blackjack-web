module BlackJackRuler
  CARDS = { 
    "A" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7,
    "8" => 8, "9" => 9, "10" => 10, "J" => 10, "Q" => 10, "K" => 10
    }.freeze

  SUITES = { "Club" => "♣", "Square" => "♦", "Heart" => "♥", "Spade" => "♠"}.freeze
  BLACKJACK = 21.freeze

  STATUS = {win: "WIN", lose: "LOSE", tie: "TIE", unknown: ""}
end

class Player
  attr_accessor :cards, :status
  attr_reader :name

  def initialize(name)
    @name = name
    @status = BlackJackRuler::STATUS[:unknown]
    @cards = []
  end

  def get_score
    value = 0
    cards.each {|card| value += BlackJackRuler::CARDS[card[1]]}
    has_ace_card = !cards.select {|card| card[1] == "A"}.empty?
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
  end

  def hit?
    return false if busted? || blackjack?
    print "#{name}: Hit or Stay (y/n):"
    gets.chomp.downcase == 'y'
  end

  def get_a_card(card)
    @cards << card
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
  attr_accessor :players

  def initialize(name, players)
    super(name)
    @players = players
  end

  def hit?
    return false if busted? || blackjack?

    print "Now, Dealer's Action."
    2.times do
      sleep 1
      print "."
    end
    puts ""
    
    return true if get_score < 17
    result = false
    players.each do |player|
      if player.status == BlackJackRuler::STATUS[:unknown] &&
        get_score < player.get_score
        result = true
      end    
    end
    result
  end
end

class Cards
  attr_reader :cards

  def initialize(poker_count = 1)
    @cards = []
    poker_count.times do 
      BlackJackRuler::SUITES.values.each do |suite|
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
  attr_accessor :dealer, :players, :cards, :current_player_index, :dealer_stop_hit
  def initialize(players)
    @players = []
    @players << players
    @dealer = Dealer.new("Dealer", players)
    @cards = Cards.new
    @current_player_index = 0
    @dealer_stop_hit = false
  end

  def reset
    @dealer.reset
    @cards = Cards.new
    @players.each {|player| player.reset}
    @current_player_index = 0
    @dealer_stop_hit = false
  end

  def deal_initial_cards_to_everyone
    reset
    2.times do 
      players.each do |player|
        cards.deal_a_card(player)
      end
      cards.deal_a_card(dealer)
    end
  end

  def asking_player_hit_again?
    return false if current_player_index >= players.size
    player = players[current_player_index]
    if player.hit?
      cards.deal_a_card(player)
    else
      @current_player_index += 1
    end
  end

  def asking_dealer_hit_again?
    if !dealer.hit?
      @dealer_stop_hit = true
      return false
    end
    cards.deal_a_card(dealer)
  end

  def update_status

    players.each do |player|
      if player.status == BlackJackRuler::STATUS[:unknown]
        
        player.status = BlackJackRuler::STATUS[:lose] if player.busted?
        player.status = BlackJackRuler::STATUS[:win] if player.blackjack?
        
        next unless dealer_stop_hit

        if dealer.busted?
          player.status = BlackJackRuler::STATUS[:win] 
        
        elsif player.get_score < dealer.get_score
          player.status = BlackJackRuler::STATUS[:lose]
           
        elsif player.get_score > dealer.get_score
          player.status = BlackJackRuler::STATUS[:win]

        elsif player.get_score == dealer.get_score
          player.status = BlackJackRuler::STATUS[:tie] if !player.blackjack?
        end
      end
    end
  end


  def show(hidden_card = true)
    system("clear")
    puts "<----------------  [ DECK ]  ----------------->"
    puts ""

    format_string = "%16s"

    print format_string % dealer.name
    players.each_with_index do |player, index|
      print_string = (index == current_player_index ? "-> " : "") + player.name
      print format_string % print_string
    end
    puts ""

    count = dealer.cards.size
    players.each do |player| 
      if player.cards.size > count 
        count = player.cards.size
      end
    end

    count.times do |index|
      if index == 1 && hidden_card
        print format_string % "[*hidden*]"
      else
        print format_string % dealer.cards[index].to_s
      end

      players.each do |player| 
        print format_string % player.cards[index].to_s
      end
      puts ""
    end

    puts "\n"
    print format_string % (hidden_card ? "" : dealer.get_score)
    players.each {|player| print format_string % player.get_score}

    puts "\n"
    print format_string % ""
    players.each {|player| print format_string % player.status}

    puts "\n"
    puts "<--------------------------------------------->"
  end

end

class BlackJackGame
  attr_accessor :deck, :players

  def initialize
    @players = []
    create_players
    @deck = Deck.new(@players)
  end

  def say(message)
    puts "=> #{message}"
  end

  def create_players
    players.clear
    say "Players count: (1 ~ 4)"
    players_count = gets.chomp.to_i until (1..4).include?(players_count)
    
    say "Player's name:"
    player_name = gets.chomp
    player_name = "Player" if player_name.empty?
    @players << Player.new(player_name)

    (players_count - 1).times do |index|
      player_name = "NPC-#{index + 1}"
      @players << RobotPlayer.new(player_name)
    end
  end

  def play
    
    loop do
      deck.deal_initial_cards_to_everyone
      
      hidden_dealer_card = true
      loop do 
        deck.show(hidden_dealer_card)

        if !deck.asking_player_hit_again?
          hidden_dealer_card = false
          break if !deck.asking_dealer_hit_again?
        end

        deck.update_status
      end

      deck.update_status
      deck.show(hidden_dealer_card)

      say "Play again? (y/n)"
      break if gets.chomp.downcase == 'n'
    end
  end
end