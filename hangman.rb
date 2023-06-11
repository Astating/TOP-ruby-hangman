# frozen_string_literal: true

# Hangman game
class Game
  attr_accessor :word, :remaining_guesses, :already_guessed

  def initialize
    @word = choose_random_word
    @remaining_guesses = 10
    @already_guessed = []
  end

  def choose_random_word
    chosen_word = nil
    File.open('google-1000-english.txt', 'r') do |file|
      five_to_twelve_long_word_list = file.readlines.map(&:chomp).filter { |word| word.length.between?(5, 12) }
      chosen_word = five_to_twelve_long_word_list.sample
    end
    chosen_word
  end

  def guess_letter(letter)
    lowercase_letter = letter.downcase
    return 'One character only. Please try again.' if letter.length != 1
    return 'Character not allowed. Use the roman alphabet only.' unless ('a'..'z').include?(lowercase_letter)
    return 'Hey, you\'ve already tried that one. Try another.' if @already_guessed.include?(lowercase_letter)

    @already_guessed.push(lowercase_letter)

    return 'Success' if @word.include?(lowercase_letter)

    @remaining_guesses -= 1
    'Death looms closer'
  end

  def game_end?
    return 'You live!' if (@word.chars - @already_guessed).empty?
    return 'You die!' if @remaining_guesses.zero?
  end

  def wrong_guesses
    @already_guessed - @word.chars
  end
end

class CLIDisplay
  def initialize
    @game = Game.new
    game_loop
  end

  def game_loop
    loop do
      p 'Hello, player !'
      p(@game.word.chars.map do |char|
        @game.already_guessed.include?(char) ? char : '_'
      end)
      p "Remaining guesses: #{@game.remaining_guesses}"
      p 'Your guess?'
      guess = gets.chomp
      p @game.guess_letter(guess)
      break if @game.game_end?
    end
  end
end

CLIDisplay.new
