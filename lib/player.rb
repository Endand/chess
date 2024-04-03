# Handles player movement and input validation

class Player
   attr_reader :name, :color

   def initialize(name, color)
     @name = name.strip.capitalize
     @color = color
   end

   #Choose an action, returns old and new location.
   def make_move
    [choose_old,choose_new]
   end

   #Choose a piece to move, if possible.
   def choose_old
    from_where_prompt
    convert_input(get_input)
   end

   #Choose a cell to move to, if possible.
   def choose_new
    to_where_prompt
    convert_input(get_input)
   end

   def get_input
    input=""
    until valid_input?(input)
      ask_input_prompt
      input=gets.strip.downcase
      input_error_message unless valid_input?(input)
    end
    input
   end

   #Converts player input to index of the board
   def convert_input(input)
    #col
    letter= alphabet_to_int(input[0]) - 1
    #row
    number= 8 - (input[1].to_i)
    #To read as nested array coord
    [number,letter]
   end

   def alphabet_to_int(letter)
    letter.downcase.ord - 'a'.ord + 1
   end

   def from_where_prompt
    puts "\nPlease select a piece to move.\n"
   end
   
   def to_where_prompt
    puts "\nPlease select where to move to.\n"
   end

   def ask_input_prompt
    puts "\nPlease enter a letter followed by a number (e.g. 'A1')\n"
   end

   def input_error_message
    puts "\nInvalid input. Please enter a letter (A-H) followed by a number (1-8) (e.g. 'A1').\n"
   end

   #Checks if input starts with A-H and then with 1-8
   def valid_input?(input)
    input.match?(/[a-h][1-8]/)
  end
end
