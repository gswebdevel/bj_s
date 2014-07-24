require 'rubygems'
require 'sinatra'

set :sessions, true

class Player
  attr_accessor :name, :hand, :current_wins
  @@number_of_players = 0

  def initialize(name)
    @name = name
    @@number_of_players += 1
    self.hand = Hand.new
    self.current_wins = 0
  end

  def self.number_of_players
    @@number_of_players
  end

end

class Hand
  attr_accessor :hand_cards, :hand_value

  def initialize
    self.hand_cards = []
    self.hand_value = 0
  end

  def add_a_card(one_card)
    self.hand_cards << one_card
  end

  def hand_value
    #puts "made it here"
    #puts self.hand_cards.count
    #p self.hand_cards
    #  if self.hand_cards.count < 2
    #   return 0
    # end
    card_value = {"A"=>11,"K"=>10,"Q"=>10,"J"=>10,"10"=>10,"9"=>9,"8"=>8,"7"=>7,"6"=>6,"5"=>5,"4"=>4,"3"=>3,"2"=>2}

    # hand = ["A","A","Q"]

    #puts self.hand_cards
    hand_sorted = self.hand_cards.sort_by{|x| card_value[x]}
    # puts hand_sorted

    current_value = 0
    hand_sorted.each do |one_card|
      # if (card_value[one_card] != nil)
      current_value = current_value + card_value[one_card]
      if current_value > 21 && one_card == "A"
        current_value = current_value - 10
      end
      # else
      #   current_value = current_value + one_card.to_i
      # end

    end
    current_value
  end

  def hit_or_stay(shuffled_deck)
    hit_one_card = "h"

    while hit_one_card != "s" && self.hand_value < 21 && self.hand_cards.count < 5
      puts "Your hand is currently #{self.hand_cards}"
      puts "Card value of your hand is #{self.hand_value}"

# want to hit or not
      puts
      puts "Would you like to Hit or Stay? (H or S)"
      hit_one_card = gets.chomp
      hit_one_card.downcase!
#puts hit_one_card

      if (hit_one_card == "h")
        add_a_card(shuffled_deck.pop)
      elsif hit_one_card == "s"
        #puts player.hand
        #puts player.hand_value
        hit_one_card = "s"
      else
        puts "Please make sure you enter a H or S"
      end

    end

  end

  def hit_or_stay_dealer(shuffled_deck)

    puts "The dealer hand is currently #{self.hand_cards}"
    puts "Card value of the dealer hand is #{self.hand_value}"

    while self.hand_value < 17
      add_a_card(shuffled_deck.pop)
      puts
      puts "Dealer hits a #{self.hand_cards.last}"

      puts "The dealer hand is currently #{self.hand_cards}"
      puts "Card value of the dealer hand is #{self.hand_value}"
    end

  end

end

class Deck
  attr_accessor :current_deck_shuffled

  def initialize(number_of_decks)
    current_deck = []
    current_deck = create_full_deck(current_deck,number_of_decks)
    #puts current_deck
    self.current_deck_shuffled = shuffle_deck(current_deck,52*number_of_decks)
  end

  def create_full_deck(current_deck, number_of_decks)
    while number_of_decks >= 0
      current_deck += one_deck_of_cards
      number_of_decks -=  1
    end
    current_deck
  end

  def one_deck_of_cards()
    face_cards = ["K","Q","J"]
    count_cards = ["2","3","4","5","6","7","8","9","10"]
    ace = ["A"]
    (face_cards+count_cards+ace)+(face_cards+count_cards+ace)+(face_cards+count_cards+ace)+(face_cards+count_cards+ace)
  end

  def shuffle_deck(cards, number_of_cards)
    x=number_of_cards-1
    shuffled_deck = []
    while x > 0
      rand_index = rand(0..x)
      shuffled_deck << cards[rand_index]
      cards.delete_at(rand_index)
      x -= 1
    end
    shuffled_deck
  end

end

class Game

  attr_accessor :player_dealer, :player_one, :session

  def initialize(player_name, session)

    #puts "What is your name: "
   # player_name = gets.chomp

    @player_dealer = Player.new("Dealer")
    @player_one = Player.new(player_name)

    session[:player_dealer] = @player_dealer
    session[:player_one] = Player.new(player_name)

  end

  def start_play_game(session)
   # play_more = "y"

   # while play_more != "N"

      shuffled_deck = Deck.new(4)

      session[:shuffled_deck] = shuffled_deck

      @player_one.hand = Hand.new
      @player_dealer.hand = Hand.new

      #puts

      @player_one.hand.add_a_card(shuffled_deck.current_deck_shuffled.pop)
      @player_dealer.hand.add_a_card(shuffled_deck.current_deck_shuffled.pop)
      @player_one.hand.add_a_card(shuffled_deck.current_deck_shuffled.pop)
      @player_dealer.hand.add_a_card(shuffled_deck.current_deck_shuffled.pop)


      #puts "The player #{@player_dealer.name} is showing a #{@player_dealer.hand.hand_cards[1]}"
      #puts
      #puts "Player: #{@player_one.name} cards are #{@player_one.hand.hand_cards} for a total of #{@player_one.hand.hand_value}"

      #  now lets play
      #puts

      #@player_one.hand.hit_or_stay(shuffled_deck.current_deck_shuffled)

     # if @player_one.hand.hand_value > 21
     #   message = "You busted, your hand of '#{@player_one.hand.hand_cards.join("','")}' has a hand value of #{@player_one.hand.hand_value}"
     #   puts message
     # end

      # now deal to dealer
     # @player_dealer.hand.hit_or_stay_dealer(shuffled_deck.current_deck_shuffled)

     # puts
     # puts "player #{@player_one.name} cards are #{@player_one.hand.hand_cards} with a total of #{@player_one.hand.hand_value}"
     # puts
     # calculate_winner(@player_one, @player_dealer)
     # puts
     # puts "Current score is you #{@player_one.current_wins} and the dealer #{@player_dealer.current_wins}"
     # puts
     # puts "Play again? (N or anything)"

     # play_more = gets.chomp

      # puts play_more

    #end

  end
end



get '/play' do
  erb :get_player_name
end


post '/save_player_name' do
  @name = params[:name]
  session[:name] = @name

  current_game = Game.new(@name, session)
  current_game.start_play_game(session)

  erb :board
end


post '/hit' do
  erb :board
end




get '/start' do
  "Hello World, it's a start!!"
end


get '/nest' do
  erb :"/custom/nest"
end


