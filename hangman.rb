class Hangman
  def initialize
    load_or_start
  end

  def change_guess(letter)
    @code_word.each_with_index do |val, i|
      @current_guess[i] = letter if letter == val
    end
    display_current_state(@current_guess)
  end

  def take_command
    puts 'Guess a letter? | other options: SAVE , QUIT'
    choice = gets.strip
    choice.downcase!
    if choice == 'save'
      save_game
    elsif choice == 'quit'
      quit
    elsif choice.length == 1
      if @letters_used.include?(choice)
        puts 'You\'ve used this letter already!'
        take_command
      else
        @letters_used << choice
        change_guess(choice)
      end
    else
      puts 'Incorrect input!'
      take_command
    end
  end

  def create_guess_holder(word)
    guess = []
    word.length.times do
      guess << '-'
    end
    guess
  end

  def display_current_state(guess)
    puts "You have #{@guesses_left} guesses left!"
    puts "You have used the letters: #{@letters_used}"
    puts ''
    guess.each do |letter|
      if letter == '-'
        print ' - '
      else print " #{letter} "
      end
    end
    puts ''
  end

  def read_dictionary
    dictionary = []
    begin
      File.readlines('dict.txt').each do |line|
        line.chomp!
        dictionary << line if line.size > 5 && line.size < 13
      end
    rescue IOError => exception
      puts exception.message
      puts exception.backtrace
      puts "Couldn't read dict.txt file"
    end
    dictionary
  end

  def random_word_from(dictionary)
    dictionary.sample
  end

  def save_game
    puts 'Write a name for the game! Example: test_game1'
    name = gets.strip
    Dir.mkdir('saved_games') unless Dir.exist? 'saved_games'
    filename = "saved_games/#{name}.txt"
    File.open(filename, 'w') do |file|
      file.puts @guesses_left.to_s
      file.puts @code_word.join('').to_s
      file.puts @current_guess.join('').to_s
      file.puts @letters_used.join('').to_s
    end
    puts 'Game saved'
    quit
  end

  def won?(guess, word)
    guess == word
  end

  def run
    while @guesses_left > -1
      take_command
      if won?(@current_guess, @code_word)
        puts 'You won!'
        return
      end
      @guesses_left -= 1
    end
    puts 'You lost!'
  end

  def quit
    puts 'You\'ve quit the game!'
    exit!
  end

  def load_or_start
    puts 'Start a new game or open a previous one?'
    puts 'Commands:  new   open'
    choice = gets.strip
    choice.downcase!
    if choice == 'new'
      @guesses_left = 10
      @code_word = random_word_from(read_dictionary).split('')
      @current_guess = create_guess_holder(@code_word)
      @letters_used = []
      run
    else
      open_game
    end
  end

  def open_game
    puts "Saved games: #{Dir['saved_games/*']}"
    puts 'Type the name of the game:'
    choice = gets.strip
    begin
      File.readlines("saved_games/#{choice}.txt").each_with_index do |line, i|
        line.chomp!
        left = line if i == 0
        word = line if i == 1
        guess = line if i == 2
        used = line if i == 3
        @guesses_left = left.to_i unless left.nil?
        @code_word = word.split('') unless word.nil?
        @current_guess = guess.split('') unless guess.nil?
        @letters_used = used.split('') unless used.nil?
      end

      display_current_state(@current_guess)
    rescue IOError => exception
      puts exception.message
      puts exception.backtrace
      puts "Game doesn't exist!"
    end
    run
  end
end

new_game = Hangman.new
