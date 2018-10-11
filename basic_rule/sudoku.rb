module Sudoku
  class Cell
    attr_reader :id, :val, :possible
    
    def initialize (id, val)
      @id = id
      @val = val
      @possible = (val ? [] : (1..9).to_a)
      @block = []
    end
    
    def external_form ()
      "C-#{id/9+1}-#{id%9+1}"
    end
    
    def set_block (block)
      case block.type
      when :row then @block[0] = block
      when :column then @block[1] = block
      when :square then @block[2] = block
      end
    end
  end
  
  class Block
  
  end
  
  class Grid
  
  end
end
