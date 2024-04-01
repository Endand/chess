require_relative './pieces'

# Handles initialization and manipulation of the game board
class Board
   attr_reader :game_board

  def initialize
    @game_board = Array.new(8) { Array.new(8) { WHITE_KING } }
  end

  def display
   puts "\nCurrent Board State:\n\n"
   # Display top border
   puts '+---' * 8 + '+'

   # Display game board
   @game_board.each_with_index do |row,i|
     print '|'
     row.each_with_index do |cell,j|
      if (i + j).even?
         print "\e[47m"
      else
         print "\e[100m"
      end 

      if cell == ' '
         print " #{cell} \e[0m|"
       else
         print " #{cell} \e[0m|"
       end
     end
     puts "\n+" + '---+' * 8
   end
 end
end