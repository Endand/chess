# Handles win conditions and game logic

class Game
   attr_reader :board, :player1, :player2

  def initialize(player1_name, player2_name)
    @board = Board.new
    @player1 = Player.new(player1_name, 'white')
    @player2 = Player.new(player2_name, 'black')
  end

  def play_round
   checkmate=nil
   stalemate=nil
   turn=1
   until checkmate || stalemate
      player = which_player(turn)
      @board.display(player.color)
      move_prompt(player)
      
      #Makes a move
      input=""
      # until can_select?(input)
      #   input=player.make_move
      # end
      input=player.make_move
      old_pos,new_pos=input
      @board.update(old_pos,new_pos)
      ##Check for checkmate

      turn+=1

      #test purpose
      checkmate=true if turn==3
   end
   
  end

  def move_prompt(player)
    puts "\n#{player.name} your turn.\n"
  end

  def which_player(turn)
    player = turn.odd? ? @player1 : @player2
  end

  def can_select?(input)
    
  end

end
