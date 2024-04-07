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
   check=false
   turn=1
   until checkmate || stalemate
      player = which_player(turn)
      color=player.color
      @board.display(color)
      if check
        checked_msg(player.name)
        check=false
      else
        move_prompt(player)
      end
      
      #Makes a move
      old_pos,new_pos=get_move(player)

      #Check for promotion
      promote(old_pos,color) if promote?(old_pos,new_pos,color)

      @board.update(old_pos,new_pos)

      #Check for checkmate
      if enemy_check?(color)
        check=true
        #check if king can move
        #check if some other piece can block
          #check if still in check -> mate
      end

      
      stalemate=true if stalemate?(color)

      turn+=1

      #test purpose
      checkmate=true if turn==5
   end

   if checkmate
    checkmate_msg(player)
   elsif stalemate
    stalemate_msg
   end
   
  end

  def me_check?(color)
    my_king= my_king_spot(color)
    eye=eyed?(my_king,color)
  end

  #Return coordinate of my king
  def my_king_spot(color)
    my_king = (color=='white') ? WHITE_KING : BLACK_KING
    @board.find_coordinate(my_king)
  end
  
  #See if my king is under an attack
  def enemy_check?(color)
    enemy_king = other_king_spot(color)
    enemy_color=other_color(color) 

    eye=eyed?(enemy_king,enemy_color)
  end

  #Return coordinate of enemy king
  def other_king_spot(color)
    enemy_king = (color=='white') ? BLACK_KING : WHITE_KING
    @board.find_coordinate(enemy_king)
  end

  #Check for stalemate
  def stalemate?(color)
    #go through the whole board and find all enemy pieces
    enemy_color=other_color(color) 
    enemy_pieces=@board.find_coordinates_all(enemy_color)
    #if all pieces have no path, stalemate
    return true if all_cant_move?(enemy_pieces,enemy_color)
      
    false
  end

  #Check if every pieces have no path available
  def all_cant_move?(pieces,color)
    pieces.all? {|piece| get_path(piece,color).empty?}
  end

  

  #Return the opposite color
  def other_color(color)
    color=='white' ? 'black' : 'white'
  end

  #Change the pawn to select piece (in-place)
  def promote(pawn_pos,color)
    
    promo_alart
    response= promo_get_response

    #replace pawn in pawn_pos to select piece according to response
    change_pawn(pawn_pos,color,response)

    promoted_msg(response)
    

  end

  def change_pawn(pawn_pos,color,response)
    r,c=pawn_pos

    change_to=''
    case color
    when 'white'
      case response
      when 'queen'
        change_to=WHITE_QUEEN
      when 'rook'
        change_to=WHITE_ROOK
      when 'bishop'
        change_to=WHITE_BISHOP
      when 'knight'
        change_to=WHITE_KNIGHT
      end
    when 'black'
      case response
      when 'queen'
        change_to=BLACK_QUEEN
      when 'rook'
        change_to=BLACK_ROOK
      when 'bishop'
        change_to=BLACK_BISHOP
      when 'knight'
        change_to=BLACK_KNIGHT
      end
    end
    @board.make_change(r,c,change_to)
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
    old_pos,new_pos=[],[]
    #Check if the move makes king in check
    until king_safe?(old_pos,new_pos,player.color)
      old_pos=get_old_input(player)
      new_pos=get_new_input(player,old_pos)
      king_in_check_msg if !king_safe?(old_pos,new_pos,player.color)
    end
    [old_pos,new_pos]
  end

  #Asks for original pos until valid
  def get_old_input(player)
    input=player.choose_old
    until can_select_old?(input, player.color)
      not_your_color_msg if !match_color?(input,player.color)
      cannot_move_msg
      input=player.choose_old
    end
    input
  end

  def match_color?(input,color)
    piece=get_piece(input)
    which_color= (color=='white') ? WHITE_PIECES : BLACK_PIECES
    which_color.include?(piece)
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
    not_blocked_path=reject_blocked(path,color,from)

    not_blocked_path
  end

  #Check if moving the piece puts king into check
  def king_safe?(from,to,color)
    return false if from.empty? || to.empty?
      rf,cf=from
      rt,ct=to
      from_piece =  get_piece(from)
      @board.make_change(rf,cf," ")
      @board.make_change(rt,ct,from_piece)
      in_check = me_check?(color)
      @board.make_change(rf,cf,from_piece)
      !in_check
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
    path.reject {|spot| eyed?(spot,color)}
  end

  #Checks if a spot is eyed by enemy pieces
  def eyed?(spot,color)
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
      eyeing_piece=@board.show_coord(r+dr,c+dc) if in_bound?([r + dr, c + dc])
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
    when 'pawn'
      #Pawn can't move forward no matter the color
      accepted = blocked_pawn_path(accepted,coord,color)
    end

    accepted
  end


  #Determines if pawn is in start pos according to color
  def in_start_pos?(color,coord)
    r,c=coord
    color=='white' ? r==6 : r==1
  end

  #Get rid of path if there is a piece blocking its way
  def blocked_pawn_path(path,coord,color)
    r, c = coord
    r += add_by_color(color)
    #rejects the spot directly in front if applicable
    if get_piece([r,c])!=' '
      path=reject_if_piece(path,r,c)
      #check two tiles ahead in case pawn is in starting pos
      if in_start_pos?(color,coord)
        r += add_by_color(color)
        path=reject_spot(path,r,c)
        r -= add_by_color(color)
      end
    end
    if in_start_pos?(color,coord)
      r += add_by_color(color)
      path=reject_if_piece(path,r,c)
    end
    path
  end

  def add_by_color(color)
    color == 'white' ? -1 : 1
  end

  #If there is a piece on the [r,c], reject from path
  def reject_if_piece(path,r,c)
    path.reject do |spot| 
      piece=get_piece(spot)
      piece!=' ' && spot == [r, c] 
    end
  end

  #Does not check if it's empty
  def reject_spot(path,r,c)
    path.reject do |spot| 
      piece=get_piece(spot)
      spot == [r, c] 
    end
  end

  #Get rid of blocked path according to piece type
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

  #If blocked by a piece, get rid of the path beyond it
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

  def not_your_color_msg
    puts "\nPlease select YOUR piece.\n"
  end

  def cannot_move_msg
    puts "\nPlease select a piece to move that could MOVE.\n"
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

  def checked_msg(name)
    puts "\n#{name}, you are in check.\n"

  end
  def king_in_check_msg
    puts "\nKing is in check! Select a move to make him safe!\n"
  end

end
