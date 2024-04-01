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
   @game_board.each do |row|
     print '|'
     row.each do |cell|
       if cell == ' '
         print " #{cell} |"
       else
         print " #{cell} |"
       end
     end
     puts "\n+" + '---+' * 8
   end
 end
end