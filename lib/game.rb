# Handles win conditions and game logic

class Game
   attr_reader :board, :player1, :player2

  def initialize(player1_name, player2_name)
    @board = Board.new
    @player1 = Player.new(player1_name, 'white')
    @player2 = Player.new(player2_name, 'black')
  end

  def play_round
   winner=nil
   turn=1
   until winner
      player = turn.odd? ? @player1 : @player2
      @board.display(player.color)
      
      ##makes a move
      puts "#{player} made a move"
      ##check for checkmate

      @board.flip
      turn+=1

      #test purpose
      winner=true if turn==3
   end
  end

end
