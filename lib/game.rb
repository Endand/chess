require_relative './pieces'
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

      #Check for promotion
      promote(old_pos) if promote?(old_pos,new_pos,player.color)

      @board.update(old_pos,new_pos)

      ##Check for checkmate

      ##Check for stalemate

      turn+=1

      #test purpose
      checkmate=true if turn==3
   end

   if checkmate
    checkmate_msg(player)
   elsif stalemate
    stalemate_msg
   end
   
  end

  #Change the pawn to select piece
  def promote(pawn_pos)
    
    promo_alart
    response= promo_get_response

    ##replace pawn in pawn_pos to select piece according to response


    promoted_msg(response)
    

  end

  #Check the move makes the pawn promotable
  def promote?(old_pos,new_pos,color)
    piece=get_piece(old_pos)
    return false if !PAWN.include?(piece)
    
    row,col=new_pos
    case color
    when 'white'
      ready = (row==0)
    when 'black'
      ready = (row==7)
    end
    ready
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

    piece=get_piece(input)
    
    # Check if the piece is empty
    return false if piece==' ' 

    # Check if the piece doesn't match the player's color
    return false if !same_color?(piece,color)

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

  #Get all the possible moveset possible
  def get_path(from,color)
    piece_type = coord_to_piece_type(from)

    path=nil
    case piece_type
    when 'king'
      path = king_path(from,color)
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
    path=reject_blocked(path,color,from)

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
  def king_path(coord,color)
    dirs=[[-1,-1],[-1,0],[0,1],[-1,1]] #LD,U,R,RD
    path = add_all_dirs(coord,dirs)
    path=remove_guarded(path,color)
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
    path = rook_path(coord) + bishop_path(coord)
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

  #Remove all the king's path that are eyed by enemy pieces
  def remove_guarded(path,color)
    path.reject {|spot| guarded?(spot,color)}
  end

  #Checks if a spot is guarded by enemy pieces
  def guarded?(spot,color)
    king_eyed?(spot,color) ||
    pawn_eyed?(spot,color) ||
    knight_eyed?(spot,color) ||
    rook_eyed?(spot,color) ||
    bishop_eyed?(spot,color) ||
    queen_eyed?(spot,color)
  end

  #Checks if an enemy pawn eyes over any of the path
  def pawn_eyed?(spot,color)
    if color=='white'
      dirs=[[-1,-1],[-1,1]]
    else
      dirs=[[1,-1],[1,1]] 
    end
    piece_there?(dirs,spot,color,PAWN)
  end

  #Checks if an enemy king eyes over any of the path
  def king_eyed?(spot,color)
    dirs=[[-1,-1],[-1,0],[0,1],[-1,1],[1,1],[1,0],[0,-1],[1,-1]] 
    piece_there?(dirs,spot,color,KING)
  end

  #Checks if an enemy knight eyes over any of the path
  def knight_eyed?(spot,color)
    dirs=[[1, 2], [2, 1], [-1, 2], [-2, 1], [-1, -2], [-2, -1], [1, -2], [2, -1]]
    piece_there?(dirs,spot,color,KNIGHT)
  end

  #Checks if an enemy rook eyes over any of the path
  def rook_eyed?(spot,color)
    dirs=[[0, 1], [0, -1], [1, 0], [-1, 0]]
    piece_in_direction?(dirs,spot,color,ROOK)
  end

  #Checks if an enemy bishop eyes over any of the path
  def bishop_eyed?(spot,color)
    dirs=[[1, 1], [-1, -1], [1, -1], [-1, 1]]
    piece_in_direction?(dirs,spot,color,BISHOP)
    
  end

  #Checks if an enemy queen eyes over any of the path
  def queen_eyed?(spot,color)
    dirs=[[1, 1], [-1, -1], [1, -1], [-1, 1]] + [[0, 1], [0, -1], [1, 0], [-1, 0]]
    piece_in_direction?(dirs,spot,color,QUEEN)
  end

  def piece_in_direction?(dirs,spot,color,type)
    dirs.each do |dr,dc|
      r,c=spot
      while in_bound?([r + dr, c + dc])
        r += dr
        c += dc
        eyeing_piece=@board.show_coord(r,c)
        if eyeing_piece!=" "
          if !same_color?(eyeing_piece,color) && type.include?(eyeing_piece)
            return true
          else
            break
          end
        end
      end
    end
    false
  end

  def piece_there?(dirs,spot,color,type)
    dirs.each do |dr,dc|
      r,c=spot
      eyeing_piece=@board.show_coord(r+dr,c+dc)
      return true if !same_color?(eyeing_piece,color) && type.include?(eyeing_piece)
    end
    false
  end

  #Reduces possible moves if the path is blocked by same colored piece
  def reject_blocked(path,color,coord)

    #covers pawn,king,knight
    accepted=no_friendly_fire(path,color)

    #covers rook,bishop,queen
    piece_type = coord_to_piece_type(coord)
    case piece_type
    when 'rook', 'bishop', 'queen'
      accepted = remove_blocked_path(accepted, color, coord)
    end

    #Pawn can't move forward no matter the color
    piece_type = coord_to_piece_type(coord)
    accepted=pawn_block_check(accepted,coord,color) if piece_type=='pawn'

    accepted
  end

  def remove_blocked_path(path,color,coord)
    piece_type = coord_to_piece_type(coord)
    case piece_type
    when 'rook'
      path=gbp_rook(coord,path)
    when 'bishop'
      path=gbp_bishop(coord,path)
    when 'queen'
      path=gbp_queen(coord,path)
    end
    path
  end

  def gbp_rook(coord,path)
    dirs=[[0, 1], [0, -1], [1, 0], [-1, 0]]
    path=get_blocked_path(dirs,coord,path)
  end
  
  def gbp_bishop(coord,path)
    dirs=[[1, 1], [-1, -1], [1, -1], [-1, 1]]
    path=get_blocked_path(dirs,coord,path)
  end

  def gbp_queen(coord,path)
    dirs=[[1, 1], [-1, -1], [1, -1], [-1, 1]] + [[0, 1], [0, -1], [1, 0], [-1, 0]]
    path=get_blocked_path(dirs,coord,path)
  end

  def get_blocked_path(dirs,coord,path)
    dirs.each do |dr,dc|
      r,c=coord
      blocked=false
      while in_bound?([r + dr, c + dc])
        r += dr
        c += dc
        
        if blocked && path.include?([r,c])
          path.delete([r,c])
        end

        if @board.show_coord(r,c)!=' '
          blocked=true
        end
      end
    end
    path
  end

  #Gets rid of path if an ally is on it
  def no_friendly_fire(path,color)
    no_same_color=path.reject do |candidate| 
      piece = get_piece(candidate)
      same_color?(piece,color)
    end
  end

  def pawn_block_check(path,coord,color)
    r, c = coord
    r += (color == 'white' ? -1 : 1)
    path.reject { |spot| spot == [r, c] }
  end

  #Checks if coord is within the chess board
  def in_bound?(coord)
    r,c=coord
    (0..7).include?(r) && (0..7).include?(c)
  end

  #Gets the element of the board based on input coordinate
  def get_piece(input)
    row,col=input
    @board.show_coord(row, col)
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

  def coord_to_piece_type(coord)
    piece = get_piece(coord)
    piece_type = get_piece_type(piece)
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

  def checkmate_msg(player)
    puts "\nCheckmate. You win #{player.name}.\n"
  end

  def stalemate_msg
    puts "\nStalemate. It is a tie.\n"
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

  def promo_alart
    puts "\nYour pawn reached the end of the board.\n"
  end

  #Asks for which piece to promote
  def promo_get_response
    choices=['queen','rook','bishop','knight']
    promo_select_msg(choices)
    response=gets.strip.downcase
    until choices.include?(response)
      not_valid_promo_piece_msg
      promo_select_msg(choices)
      response=gets.strip.downcase
    end
    response
  end

  def promo_select_msg(choices)
    puts "\nSelect a piece to promote to: #{choices.inspect}\n"
  end

  def not_valid_promo_piece_msg
    puts "\nThat is not an option.\n"
  end

  def promoted_msg(response)
    puts "\nYour pawn is promoted to a #{response}!\n"
  end

end
