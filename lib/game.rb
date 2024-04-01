# Handles win conditions and game logic

class Game
   attr_reader :board, :player1, :player2

  def initialize(player1_name, player2_name)
    @board = Board.new
    @player1 = Player.new(player1_name, 'white')
    @player2 = Player.new(player2_name, 'black')
  end

  def play_round
   @board.display
  end

end
