require 'rubygems'
require 'sinatra'

set :sessions, true

class Player
  attr_accessor :name, :hand, :current_wins, :playing_now
  @@number_of_players = 0

  def initialize(name)
    @name = name
    @@number_of_players += 1
    self.hand = Hand.new
    self.current_wins = 0
    @playing_now = false
  end

  def self.number_of_players
    @@number_of_players
  end

  def player_busted
    # do who wins logic
    if hand.hand_value > 21
      return true
    end
  end

  def player_black_jack
    # do who wins logic
    if hand.hand_value == 21 && hand.hand_cards.count == 2
      return true
    end
  end
  def player_5_cards_under_21
    # do who wins logic
    if hand.hand_value < 21 && hand.hand_cards.count == 5
      return true
    end
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
    card_value = {"A"=>11,"K"=>10,"Q"=>10,"J"=>10,"10"=>10,"9"=>9,"8"=>8,"7"=>7,"6"=>6,"5"=>5,"4"=>4,"3"=>3,"2"=>2}

    hand_sorted = self.hand_cards.sort_by{|x| card_value[x]}
    # puts hand_sorted

    current_value = 0
    hand_sorted.each do |one_card|
      # if (card_value[one_card] != nil)
      current_value = current_value + card_value[one_card]
      if current_value > 21 && one_card == "A"
        current_value = current_value - 10
      end

    end
    current_value
  end

  def hit_or_stay(shuffled_deck)

   add_a_card(shuffled_deck.pop)
  #  add_a_card("A")

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

  attr_accessor :player_dealer, :player_one, :shuffled_deck

  def initialize(player_name)

    @player_dealer = Player.new("Dealer")
    @player_one = Player.new(player_name)

  end

  def start_play_game

      @shuffled_deck = Deck.new(1)

      player_one.hand = Hand.new
      player_dealer.hand = Hand.new
      player_one.playing_now = true
      #puts

      player_one.hand.add_a_card(shuffled_deck.current_deck_shuffled.pop)
      player_dealer.hand.add_a_card(shuffled_deck.current_deck_shuffled.pop)
      player_one.hand.add_a_card(shuffled_deck.current_deck_shuffled.pop)
      player_dealer.hand.add_a_card(shuffled_deck.current_deck_shuffled.pop)

  end

  def game_over
    player_dealer.playing_now && player_one.playing_now
  end

  def calculate_winner
    # do who wins logic
    if player_dealer.hand.hand_value > 21
      player_one.current_wins += 1
      return  "Dealer busted, dealer hand of '#{player_dealer.hand.hand_cards.join("','")}' has a hand value of #{player_dealer.hand.hand_value}"
    elsif player_one.hand.hand_value > 21
      player_dealer.current_wins += 1
      return "You busted, your hand of '#{player_one.hand.hand_cards.join("','")}' has a hand value of #{player_one.hand.hand_value}"
    elsif player_one.player_5_cards_under_21
      player_one.current_wins += 1
      return "You WIN, your hand of '#{player_one.hand.hand_cards.join("','")}' has a hand value of #{player_one.hand.hand_value} and is 5 cards"
    elsif player_one.hand.hand_value > player_dealer.hand.hand_value
      player_one.current_wins += 1
      return "You WIN"
    elsif player_one.hand.hand_value <= player_dealer.hand.hand_value
      player_dealer.current_wins += 1
      return "Sorry #{player_one.name} you LOSE"
    end

  end


end


helpers do
  def calculate_current_money

  end
  def card_images(cards)
    card_image_html = ""
    card_name = {"A"=>"ace","K"=>"king","Q"=>"queen","J"=>"jack","10"=>"10","9"=>"9","8"=>"8","7"=>"7","6"=>"6","5"=>"5","4"=>"4","3"=>"3","2"=>"2"}
    cards.each do |one_card|

      card_image_html += "<img src = images/cards/clubs_#{card_name[one_card]}.jpg height=\"115\" width=\"80\">"
    end
    card_image_html
  end
end


get '/play' do
  erb :get_player_name
end


post '/save_player_name' do
  @name = params[:name]
  #session[:name] = @name

  session[:current_game] = Game.new(@name)
  redirect '/play_again'
#  session[:current_game].start_play_game

#  erb :board
end


post '/hit' do
  session[:current_game].player_one.hand.hit_or_stay(session[:current_game].shuffled_deck.current_deck_shuffled)
  if session[:current_game].player_one.player_busted
    session[:current_game].player_dealer.playing_now = true
  end
  if session[:current_game].player_one.player_5_cards_under_21
    session[:current_game].player_dealer.playing_now = true
  end


  erb :board
end

post '/stay' do
  session[:current_game].player_dealer.playing_now = true
  session[:current_game].player_dealer.hand.hit_or_stay_dealer(session[:current_game].shuffled_deck.current_deck_shuffled)


  erb :board
end


get '/play_again' do
  player_wins = session[:current_game].player_one.current_wins
  dealer_wins = session[:current_game].player_dealer.current_wins
#  player_name = session[:current_game].player_dealer.current_wins
  session[:current_game] = Game.new(session[:current_game].player_one.name)
  session[:current_game].start_play_game

  session[:current_game].player_one.current_wins = player_wins
  session[:current_game].player_dealer.current_wins = dealer_wins

  if session[:current_game].player_one.player_black_jack || session[:current_game].player_dealer.player_black_jack
    session[:current_game].player_dealer.playing_now = true
  end


  erb :board
end




get '/start' do
  "Hello World, it's a start!!"
end


get '/nest' do
  erb :"/custom/nest"
end
