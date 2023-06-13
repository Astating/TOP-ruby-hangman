# frozen_string_literal: true

require 'set'
require 'yaml'

# Hangman game
class Game
  attr_accessor :word, :remaining_guesses, :already_guessed

  def initialize(load: false)
    if load
      load_game
    else
      @word = choose_random_word
      @remaining_guesses = 6
      @already_guessed = Set.new
    end
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

    @already_guessed.add(lowercase_letter)

    return 'Success' if @word.include?(lowercase_letter)

    @remaining_guesses -= 1
    'Death looms closer'
  end

  def game_end?
    return 'You live!' if (@word.chars.to_set - @already_guessed).empty?
    return 'You die!' if @remaining_guesses.zero?
  end

  def wrong_guesses
    @already_guessed - @word.chars
  end

  def to_yaml
    File.open('game-save', 'w+') do |f|
      YAML.dump({ word: word, remaining_guesses: remaining_guesses, already_guessed: already_guessed }, f)
    end
  end

  def load_game
    save = YAML.safe_load_file('game-save', permitted_classes: [Symbol, Set])

    @word = save[:word]
    @remaining_guesses = save[:remaining_guesses]
    @already_guessed = save[:already_guessed]
  end
end

# Handles and game prompts and display
class CLIDisplay
  def initialize
    @game = ask_load_game ? Game.new(load: true) : Game.new
    game_loop
  end

  def ask_load_game
    loop do
      puts 'Press L to load your save. Press N to start a new game.'
      answer = gets.chomp.downcase
      return true if answer == 'l'
      return false if answer == 'n'
    end
  end

  def game_loop
    puts
    puts 'Hello, player !'

    loop do
      puts
      ask_save
      puts
      word_display
      guess_display
      puts
      ask_guess
      break if @game.game_end?
    end
    puts @game.game_end? + " Word was #{@game.word}"
    puts
    ask_exit_or_play
  end

  def word_display
    puts(@game.word.chars.map do |char|
      @game.already_guessed.include?(char) ? char : '_'
    end.join(' '))
  end

  def guess_display
    puts "Remaining guesses: #{@game.remaining_guesses}"
    puts "Wrong guesses: #{@game.wrong_guesses.join(', ')}"
  end

  def ask_guess
    puts 'Your guess?'
    guess = gets.chomp
    puts @game.guess_letter(guess)
  end

  def ask_save
    loop do
      puts 'Save the game ? (y/n)'

      answer = gets.chomp.downcase
      @game.to_yaml if answer == 'y'
      break if %w[y n].include?(answer)
    end
  end

  def ask_exit_or_play
    loop do
      puts 'Exit (e) or continue (c) ?'

      answer = gets.chomp.downcase

      exit if answer == 'e'
      initialize if answer == 'c'
    end
  end
end

CLIDisplay.new
