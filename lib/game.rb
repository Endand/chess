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
      old_pos,new_pos=get_move(player)
      @board.update(old_pos,new_pos)

      ##Check for checkmate
      ##Check for stalemate

      turn+=1

      #test purpose
      checkmate=true if turn==3
   end
   
  end

  def move_prompt(player)
    puts "\n#{player.name} your turn.\n"
  end

  #Determines which player's turn
  def which_player(turn)
    player = turn.odd? ? @player1 : @player2
  end

  #Take inputs from player for start and end position
  def get_move(player)
    
    old_pos=get_old_input(player)
    new_pos=get_new_input(player,old_pos)
    [old_pos,new_pos]
  end

  #Asks for original pos until valid
  def get_old_input(player)
    input=""
    until can_select_old?(input, player.color)
      input=player.choose_old
      not_valid_old unless can_select_old?(input, player.color)
    end
    input
  end

  #Asks for new pos until valid
  def get_new_input(player,from)
    input=""
    until can_select_new?(input,from)
      input=player.choose_new
    end
    input
  end


  #Check if piece to move exists in the coord and is player's color.
  def can_select_old?(input,color)
    return false if input==""

    row,col=input
    piece= @board.show_coord(row, col)
    piece!=' ' && right_color?(piece,color)
  end

  #Check if current piece matches player color
  def right_color?(piece,color)
    color=='white' ? WHITE_PIECES.include?(piece) : BLACK_PIECES.include?(piece)
  end

  def not_valid_old
    puts "\nPlease select YOUR piece to move.\n"
  end

  def can_select_new?(input,from)
    
    #placeholder
    true
  end



end
