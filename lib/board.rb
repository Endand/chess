require_relative './pieces'

# Handles initialization and manipulation of the game board
class Board
   attr_reader :game_board

  def initialize
    @game_board = Array.new(8) { Array.new(8) { " " } }
    chess_pieces_init
  end

  #Fill board with pieces on their starting pos
  def chess_pieces_init
   piece_place('white')
   piece_place('black')
   init_test
  end

  def init_test

    @game_board[4][3] = WHITE_QUEEN
    @game_board[3][3] = WHITE_QUEEN
    @game_board[5][3] = WHITE_QUEEN
    @game_board[1][4] = " "
    @game_board[0][3] = " "
    @game_board[0][6] = " "
    

  end
  
  #Fill one side of the board with pieces
  def piece_place(color)
   pawn_place(color)
   special_piece_place(color)
  end

  #Init back row pieces positions
  def special_piece_place(color)
   if color=='white'
      @game_board[7][0] = WHITE_ROOK
      @game_board[7][7] = WHITE_ROOK
      @game_board[7][1] = WHITE_KNIGHT
      @game_board[7][6] = WHITE_KNIGHT
      @game_board[7][2] = WHITE_BISHOP
      @game_board[7][5] = WHITE_BISHOP
      @game_board[7][3] = WHITE_QUEEN
      @game_board[7][4] = WHITE_KING
   elsif color=='black'
      @game_board[0][0] = BLACK_ROOK
      @game_board[0][7] = BLACK_ROOK
      @game_board[0][1] = BLACK_KNIGHT
      @game_board[0][6] = BLACK_KNIGHT
      @game_board[0][2] = BLACK_BISHOP
      @game_board[0][5] = BLACK_BISHOP
      @game_board[0][3] = BLACK_QUEEN
      @game_board[0][4] = BLACK_KING
   end
  end

  #Init pawn positions
  def pawn_place(color)
   if color=='white'
      8.times do |i|
         @game_board[6][i] = WHITE_PAWN
      end
   elsif color=='black'
      8.times do |i|
         @game_board[1][i] = BLACK_PAWN
      end
   end
   
  end

  #Shows board status with comments and coordinates
  def display(color)
   puts "\n------------------------------------------"
   puts "\nCurrent Board State:\n\n"
   # Display top border
   
   # Display game board
   show_board(color)
   
   
   col_coord(color)
 end

 #Shows current board status according to color
 def show_board(color)
  board_to_display = (color=='white') ? @game_board : flipped_board
  puts ' '+'+---' * 8 + '+'
  board_to_display.each_with_index do |row, i|
    row_coord(color,i)
    print '|'
    row.each_with_index do |cell, j|
      # Determine background color based on row and column index
      if (i + j).even?
        print "\e[47m"  # White background
      else
        print "\e[100m" # Grey background
      end

      # Print cell content
      if cell == ' '
        print " #{cell} "
      else
        print " #{cell} "
      end
      
      # Reset background color immediately after printing
      print "\e[0m|"
    end
    puts "\n +" + '---+' * 8
  end
 end

 #Flip the board for better view for black
 def flipped_board
  @game_board.reverse.map { |row| row.reverse }
 end

 #Used to determine which order to show the row num
 def row_coord(color,index)
   if color=='white'
      print 8-index
     else
      print index+1
     end
 end

 #Used to determine which order to show the col num
 def col_coord(color)
   if color=='white'
      puts "   A   B   C   D   E   F   G   H"
   else
      puts "   H   G   F   E   D   C   B   A"
   end
 end
 
 #Takes old and new pos from player and updates the board accordingly
 def update(old_pos,new_pos)
  opr,opc= old_pos
  npr,npc=new_pos
  piece= @game_board[opr][opc]
  @game_board[opr][opc]=" "
  @game_board[npr][npc]=piece
 end

 def show_coord(row,col)
  @game_board[row][col]
 end

 def make_change(row,col,change)
  @game_board[row][col]=change
 end

 def find_coordinate(target)
  @game_board.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      return [i, j] if cell == target
    end
  end
 end

 def find_coordinates_all(color)
  pieces_color =  (color=='white') ? WHITE_PIECES : BLACK_PIECES
  coordinates=[]
  @game_board.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      coordinates << [i, j] if pieces_color.include?(cell)
    end
  end
  coordinates
 end
end