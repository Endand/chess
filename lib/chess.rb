require_relative './game'
require_relative './player'
require_relative './board'
require_relative './pieces'

# Handles overall game flow and interactions
class Chess
   def play
      greeting
      player1_name = get_name(1)
      player2_name = get_name(2)
      start_round(player1_name, player2_name)
      while play_again?
         player1_name, player2_name = swap_names(player1_name, player2_name)
         new_game_msg
         start_round(player1_name, player2_name)
      end
      end_message
   end

    def greeting
      puts "\nWelcome to Chess\n"
    end
  
    def swap_names(name1, name2)
      temp = name1
      name1 = name2
      name2 = temp
  
      [name1, name2]
    end
  
    def get_name(player_num)
      ask_name(player_num)
      name = gets.strip.capitalize
    end
  
    def ask_name(player_num)
      puts "\nPlease enter name for player #{player_num}: "
    end
  
    def play_again?
      ans = ask_again
      ans == 'y'
    end
  
    def ask_again
      puts "\nPlay Again? (Y/N)\n"
      ans = ''
      ans = gets.strip.downcase[0] until %w[y n].include?(ans)
      ans
    end
  
    def end_message
      puts "\nThank you for playing!\n"
    end
  
    def new_game_msg
      puts "\nNew Game!\n"
    end

    def start_round(player1_name, player2_name)
      game = Game.new(player1_name, player2_name)
      game.play_round
    end
end
