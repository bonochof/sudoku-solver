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
    
    def empty? ()
      !@val
    end
    
    def possible_numbers ()
      @possible
    end
    
    def connected_cells ()
      @block.collect{|b| b.cell|.inject(:|) - [self]
    end
    
    def connected_empty_cells ()
      connected_cells().select{|c| c.empty?}
    end
    
    def find_single_number ()
      (@possible.length == 1 ? Rule.new(:single_number, self, @possible[0]) : nil)
    end
    
    def assign (x)
      @possible = []
      @val = x
    end
    
    def cannot_assign (x)
      @possible = @possible - [x]
    end
    
    def propagate ()
      connected_empty_cells().each do |c|
        c.cannot_assign(@val)
      end
    end
    
    def single_cell (x, block)
      assign(x)
      propagate()
    end
    
    def single_number (x)
      assign(x)
      propagate()
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
    
    def empty_cells ()
      @cell.select{|c| c.empty?}
    end
    
    def possible_cells (x)
      empty_cells().select{|s| s.possible.member?(x)}
    end
    
    def assigned_numbers ()
      @cell.select{|c| c.val}.collect{|c| c.val}
    end
    
    def free_numbers ()
      (1..9).to_a - assigned_numbers()
    end
    
    def find_single_cell ()
      free_numbers().collect{|x| ((pc = possible_cells(x)).length == 1 ? Rule.new(:single_cell, pc[0], x, self) : nil)}.compact
    end
  end
  
  class Rule
    def initialize (*args)
      @spec = args
    end
    
    def apply ()
      @spec[1].send(@spec[0], *@spec[2..-1])
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
    
    def initial_propagate ()
      @cell.each do |c|
        c.propagate() if c.val
      end
    end
    
    def find_applicable_rules (rules)
      rules.eaah do |rule|
        applicable = find_applicable_rule_instances(rule)
        return applicable if !applicable.empty?
      end
    end
    
    def find_applicable_rule_instances (rule)
      case rule
      when :single_number
        @cell.collect{|c| c.find_single_number}.compact
      when :single_cell
        @block.collect{|b| b.find_single_cell}.flatten
      end
    end
    
    def solve (rules, verbose=nil)
      self.initial_propagate
      step = 0
      
      while (!self.solved?) do
        ar = find_applicable_rules(rules)
        break if ar.empty?
        printf("[Step %02d] %02d; %s\n", step+=1, ar[0].external_form) if verbose
        ar[0].apply
      end
      self.solved?
    end
    
    def solved? ()
      !@cell.find{|c| c.empty?}
    end
    
    def show_result (pad=' ')
      print((0..8).collect{|i| @cell[9*i, 9].collect{|c| c.val || '.'}.join('')}.join(pad), "\n")
    end
  end
end
