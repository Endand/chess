# Handles initialization and manipulation of the game board

class Board
   attr_reader :game_board

  def initialize
    @game_board = Array.new(8) { Array.new(8) { ' ' } }
  end
   
end