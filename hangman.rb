# frozen_string_literal: true

class Game
  def initialize
    @word = choose_random_word
    p @word
  end

  def choose_random_word
    chosen_word = nil
    File.open('google-1000-english.txt', 'r') do |file|
      five_to_twelve_long_word_list = file.readlines.map(&:chomp).filter { |word| word.length.between?(5, 12) }
      chosen_word = five_to_twelve_long_word_list.sample
    end
    chosen_word
  end
end

Game.new
