# Handles player movement and input validation

class Player
   attr_reader :name, :color

   def initialize(name, color)
     @name = name.strip.capitalize
     @color = color
   end
end
