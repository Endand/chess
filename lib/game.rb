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
    # Ensure the input is not empty
    return false if input.empty?

    # Check if the piece is empty or doesn't match the player's color
    piece=get_piece(input)
    return false if piece==' ' || !same_color?(piece,color)

    #NEED TO ADD A CHECKER FOR NO VALID MOVE CASE
    path = get_path(input,color)
    return false if path.empty?

    # If all conditions are met, return true
    true
  end

  #Asks for new pos until valid
  def get_new_input(player, from)
    input = nil
    path = nil
  
    loop do
      input = player.choose_new
      path = get_path(from, player.color)
  
      if can_select_new?(path, input)
        break
      else
        not_valid_new
        display_possible_path(path)
      end
    end
  
    input
  end

  #Checks if selected path can move to desinated input
  def can_select_new?(path,input)
    return false if input.empty?
    
    #Checks if input is part the candidate path
    path.include?(input)
    
  end

  #Gets piece type of the piece to move
  def identify_old_piece(from)
    piece = get_piece(from)
    piece_type = get_piece_type(piece)
  end

  #Get all the possible moveset possible
  def get_path(from,color)

    piece_type= identify_old_piece(from)

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
      path = pawn_path(from,color)
    end

    #Eliminate blocked path
    path=reject_blocked(path,color)

    #test purpose
    puts "#{path.inspect}"
    path
  end

  #Gets all possible path a pawn can take
  def pawn_path(coord,color)
    path=[]
    row,col=coord
    if color=="white"
      if row==6
        path += add_to_path(coord,-2,0)
      end
      path += add_to_path(coord,-1,0)
      dirs=[[-1,-1],[-1,1]]
    elsif color=="black"
      if row==1
        path += add_to_path(coord,2,0)
      end
      path += add_to_path(coord,1,0)
      dirs=[[1,1],[1,-1]]
    end
    dirs.each do |dr,dc|
      new_coord=get_new_coord(coord,dr,dc)
      piece=get_piece(new_coord)
      path += add_to_path(coord,dr,dc) if opp_color?(piece,color)
    end
    path
  end

  #Gets all possible path a king can take
  def king_path(coord)
    dirs=[[-1,-1],[-1,0],[0,1],[-1,1]] #LD,U,R,RD
    path = add_all_dirs(coord,dirs)
  end

  #Gets all possible path a knight can take
  def knight_path(coord)
    dirs=[[2,1],[2,-1],[1,2],[1,-2]] #LD,U,R,RD
    path = add_all_dirs(coord,dirs)
  end

  #Gets all possible path a rook can take
  def rook_path(coord)
    dirs=[[0, 1], [0, -1], [1, 0], [-1, 0]]
    path= keep_adding(coord,dirs)
  end

  #Gets all possible path a bishop can take
  def bishop_path(coord)
    dirs=[[1, 1], [-1, -1], [1, -1], [-1, 1]]
    path= keep_adding(coord,dirs)
  end

  #Gets all possible path a queen can take
  def queen_path(coord)
    path= rook_path(coord) + bishop_path(coord)
  end
  
  #Add to path until end of the board
  def keep_adding(coord,dirs)
    path=[]
    dirs.each do |dr,dc|
      r,c=coord
      while in_bound?([r + dr, c + dc])
        r += dr
        c += dc
        path << [r, c]
      end
    end
    path
  end

  #Adds all possible cells to path based on the directions a piece can move
  def add_all_dirs(coord,dirs)
    path=[]
    dirs.each do |dr,dc|
      path += add_to_path(coord,dr,dc) + add_to_path(coord,-dr,-dc)
    end
    path
  end

  #Return the coord of piece to compare
  def get_new_coord(coord,dr,dc)
    row,col=coord
    new_coord=[row+dr,col+dc]
  end

  #Add one to possible path according to direction
  def add_to_path(coord,dr,dc)
    path=[]
    new_coord = get_new_coord(coord,dr,dc)
    path << new_coord if in_bound?(new_coord)
    path
  end

  #Reduces possible moves if the path is blocked by same colored piece
  def reject_blocked(path,color)
    
    #covers pawn,knight,king
    accepted=no_friendly_fire(path,color)

    accepted
  end

  #Gets rid of path if an ally is on it
  def no_friendly_fire(path,color)
    no_same_color=path.reject do |candidate| 
      piece = get_piece(candidate)
      same_color?(piece,color)
    end
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
    puts "\nPlease select YOUR piece to move that could MOVE.\n"
  end
  
  def not_valid_new
    puts "\nThat piece cannot move there.\n"
  end

  def display_possible_path(path)
    translated_path= translate_input(path)
    puts "\nHere are the options: #{translated_path.inspect}\n"
  end

  #Converts indexes to chess notation
  def translate_input(paths)
    result=[]
    paths.each do |path|
      row,col=path

      
      row=8-row
      row= row.to_s

      col = int_to_alphabet(col)

      result << col+row
    end
    result
  end

  #Converts col num to matching letter
  def int_to_alphabet(col)
    ('A'.ord + col).chr
  end

end
