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
    input=player.choose_old
    until can_select_old?(input, player.color)
      not_valid_old
      input=player.choose_old
    end
    input
  end

  #Check if piece to move exists in the coord and is player's color.
  def can_select_old?(input,color)
    return false if input.empty?
    piece=get_piece(input)
    piece!=' ' && same_color?(piece,color)
  end

  #Asks for new pos until valid
  def get_new_input(player,from)
    input = player.choose_new
    until can_select_new?(from, input, player.color)
      not_valid_new
      input = player.choose_new
    end
    input
  end

  #Checks if selected path can move to desinated input
  def can_select_new?(from,input,color)
    return false if input.empty?
    piece = get_piece(from)
    piece_type = get_piece_type(piece)
    #Get all the possible moveset possible
    path=nil
    case piece_type
    when 'king'
      path = king_path(from)
    when 'queen'
      path = queen_path(from)
    when 'rook'
      path = rook_path(from)
    when 'bishop'
      path = bishop_path(from)
    when 'knight'
      path = knight_path(from)
    when 'pawn'
      path = pawn_path(from)
    end

    #Eliminate blocked path
    path=reject_blocked(path,color)

    
    #Check if input is part the candidate path
    
    #placeholder
    true
  end

  

  def king_path(coord)
    path=[]
    dirs=[[-1,-1],[-1,0],[0,1],[-1,1]] #LD,U,R,RD
    dirs.each do |dr,dc|
      path += add_to_path(coord,dr,dc) + add_to_path(coord,-dr,-dc)
    end
    path
  end

  def pawn_path(coord)
    
  end

  def rook_path(coord)

  end

  def bishop_path(coord)

  end

  def queen_path(coord)

  end

  def knight_path(coord)

  end

  #Add one to possible path according to direction
  def add_to_path(coord,dr,dc)
    path=[]
    row,col=coord
    new_coord=[row+dr,col+dc]
    path << new_coord if in_bound?(new_coord)
    path
  end

  #Reduces possible moves if the path is blocked by same colored piece
  def reject_blocked(path,color)
    accepted=path.reject do |candidate| 
      piece = get_piece(candidate)
      same_color?(piece,color)
    end
    accepted
  end

  #Checks if coord is within the chess board
  def in_bound?(coord)
    r,c=coord
    (0..7).include?(r) && (0..7).include?(c)
  end

  #Gets the element of the board based on input coordinate
  def get_piece(input)
    row,col=input
    piece = @board.show_coord(row, col)
  end

  #Gets the type of piece
  def get_piece_type(piece)
    case piece
    when BLACK_KING, WHITE_KING
      'king'
    when BLACK_QUEEN, WHITE_QUEEN
      'queen'
    when BLACK_ROOK, WHITE_ROOK
      'rook'
    when BLACK_BISHOP, WHITE_BISHOP
      'bishop'
    when BLACK_KNIGHT, WHITE_KNIGHT
      'knight'
    when BLACK_PAWN, WHITE_PAWN
      'pawn'
    else
      'not valid piece'
    end
  end

  #Check if current piece matches player color
  def same_color?(piece,color)
    color=='white' ? WHITE_PIECES.include?(piece) : BLACK_PIECES.include?(piece)
  end

  #Checks if piece is opponent's color
  def opp_color?(piece,color)
    color=='black' ? WHITE_PIECES.include?(piece) : BLACK_PIECES.include?(piece)
  end

  def move_prompt(player)
    puts "\n#{player.name} your turn.\n"
  end

  def not_valid_old
    puts "\nPlease select YOUR piece to move.\n"
  end
  
  def not_valid_new
    puts "\nThat piece cannot move there.\n"
  end
end
