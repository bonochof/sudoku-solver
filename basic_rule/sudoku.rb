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
    attr_reader :type, :id, :cell
    
    def initialize (type, id, cell)
      @type = type
      @id = id
      @cell = cell
      
      @cell.each do |c|
        c.set_block(self)
      end
    end
    
    def external_form ()
      "#{@type.to_s}-#{@id+1}"
    end
  end
  
  class Grid
    def cell_id (i, j)
      i * 9 + j
    end
    
    def initialize (string)
      @cell = string.split(//).enum_for(:each_with_index).collect{|x, i| Cell.new(i, (x =~ /^[1-9]$/ ? x.to_i : nil))}
      @row = (0..8).collect{|i| Block.new(:row, i, @cell[9*i, 9])}
      @column = (0..8).collect{|i| Block.new(:column, i, (0..8).collect{|j| @cell[cell_id(j, i)]})}
      @square = (0..8).collect{|i| Block.new(:square, i, (0..8).collect{|j| @cell[cell_id(3*(i/3)+j/3, 3*(i%3)+j%3)]})}
      @block = @square + @row + @column
    end
  end
end
