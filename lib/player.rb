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
    [1,1]
   end
   #Choose a cell to move to, if possible.
   def choose_new
    return [0,0]
   end
end
