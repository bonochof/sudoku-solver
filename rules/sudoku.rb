module Sudoku
  class Cell
    attr_reader :id, :val, :possible, :block
    
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
    
    def in? (block)
      @block.member?(block)
    end
    
    def empty? ()
      !@val
    end
    
    def possible_numbers ()
      @possible
    end
    
    def possible? (x)
      @possible.member?(x)
    end
    
    def connected_cells ()
      @block.collect{|b| b.cell}.inject(:|) - [self]
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
    
    def cannot_assign_except (numbers, simulation=nil)
      if simulation
        !(@possible - (@possible & numbers)).empty?
      else
        @possible = @possible & numbers
      end
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
      (1..9).to_a - self.assigned_numbers()
    end
    
    def find_single_cell ()
      free_numbers().collect{|x| ((pc = possible_cells(x)).length == 1 ? Rule.new(:single_cell, pc[0], x, self) : nil)}.compact
    end
    
    def covered_block (x)
      pb = possible_cells(x).collect{|c| c.block}.inject(:&).select{|b| b != self}
      pb.length == 1 ? pb[0] : nil
    end
    
    def find_single_block ()
      free_numbers().collect{|x|
        (b = covered_block(x)) ? Rule.new(:single_block, b, x, self).effective? : nil
      }.compact
    end
    
    def single_block (x, except, simulation=nil)
      if simulation
        self.empty_cells().find{|c| !c.in?(except) && c.possible?(x)}
      else
        self.empty_cells().each do |c|
          c.cannot_assign(x) unless c.in?(except)
        end
      end
    end
    
    def find_reserve_2_cells ()
      free_numbers().combination(2).collect{|x, y|
        xpc = possible_cells(x)
        ypc = possible_cells(y)
        if xpc.length == 2 && ypc.length == 2 && (xpc - ypc).empty?
          Rule.new(:reserve_2_cells, xpc, [x, y], self).effective?
        else
          nil
        end
      }.compact
    end
    
    def find_reserve_n_cells (n)
      free_numbers().combination(n).collect{|numbers|
        pc = numbers.collect{|x| possible_cells(x)}.inject(:|)
        if pc.length == n
          Rule.new(:reserve_n_cells, n, pc, numbers, self).effective?
        else
          nil
        end
      }.compact
    end
    
    def find_reserve_2_numbers ()
      empty_cells().combination(2).collect{|ci, cj|
        cin = ci.possible_numbers()
        cjn = cj.possible_numbers()
        if cin.length == 2 && cjn.length == 2 && (cin - cjn).empty?
          Rule.new(:reserve_2_numbers, cin, [ci, cj], self).effective?
        else
          nil
        end
      }.compact
    end
    
    def find_reserve_n_numbers (n)
      empty_cells().combination(n).collect{|cells|
        pn = cells.collect{|c| c.possible_numbers()}.inject(:|)
        if pn.length == n
          Rule.new(:reserve_n_numbers, n, pn, cells, self).effective?
        else
          nil
        end
      }.compact
    end
    
    def reserve_2_numbers (numbers, except, simulation=nil)
      if simulation
        (@cell - except).find{|c| !(c.possible & numbers).empty?}
      else
        (@cell - except).each do |c|
          numbers.each do |x|
            c.cannot_assign(x)
          end
        end
      end
    end
    
    def reserve_n_numbers (n, numbers, except, simulation=nil)
      if simulation
        (@cell - except).find{|c| !(c.possible & numbers).empty?}
      else
        (@cell - except).each do |c|
          numbers.each do |x|
            c.cannot_assign(x)
          end
        end
      end
    end
    
    def cannot_assign (x, except, simulation=nil)
      if simulation
        empty_cells().find{|c| (c.block & except).empty? && c.possible.member?(x)}
      else
        empty_cells().each do |c|
          if (c.block & except).empty?
            c.cannot_assign(x)
          end
        end
      end
    end
  end
  
  class Rule
    def initialize (*args)
      @spec = args
    end
    
    def effective? ()
      apply(true) ? self : nil
    end
    
    def apply (simulation=nil)
      case @spec[0]
      when :single_number, :single_cell
        @spec[1].send(@spec[0], *@spec[2..-1])
      when :single_block
        args = @spec[2..-1] + [simulation]
        @spec[1].send(@spec[0], *args)
      when :reserve_2_cells, :reserve_n_cells
        args = @spec + [simulation]
        self.send(*args)
      when :reserve_2_numbers
        args = @spec[0, 3] + [simulation]
        @spec[3].send(*args)
      when :reserve_n_numbers
        args = @spec[0, 4] + [simulation]
        @spec[4].send(*args)
      when :igeta_2
        args = @spec + [simulation]
        self.send(*args)
      end
    end
    
    def external_form ()
      case @spec[0]
      when :single_number
        [@spec[0], @spec[1].external_form, @spec[2]].join(" ")
      when :single_cell, :single_block
        [@spec[0], @spec[1].external_form, @spec[2], @spec[3].external_form].join(" ")
      when :reserve_2_cells
        [@spec[0], @spec[1].collect{|c| c.external_form}.join(","), @spec[2].join(","), @spec[3].external_form].join(" ")
      when :reserve_n_cells
        [@spec[0], @spec[1], @spec[2].collect{|c| c.external_form}.join(","), @spec[3].join(","), @spec[4].external_form].join(" ")
      when :reserve_2_numbers
        [@spec[0], @spec[1].join(","), @spec[2].collect{|c| c.external_form}.join(","), @spec[3].external_form].join(" ")
      when :reserve_n_numbers
        [@spec[0], @spec[1], @spec[2].join(","), @spec[3].collect{|c| c.external_form}.join(","), @spec[4].external_form].join(" ")
      when :igeta_2
        [@spec[0], @spec[1], @spec[2].collect{|c| c.external_form}.join(","), @spec[3].collect{|c| c.external_form}.join(","), @spec[4].collect{|c| c.external_form}.join(",")].join(" ")
      end
    end
    
    def reserve_2_cells (cells, numbers, block, simulation=nil)
      if simulation
        cells.find{|c| c.cannot_assign_except(numbers, simulation)}
      else
        cells.each do |c|
          c.cannot_assign_except(numbers)
        end
      end
    end
    
    def reserve_n_cells (n, cells, numbers, block, simulation=nil)
      if simulation
        cells.find{|c| c.cannot_assign_except(numbers, simulation)}
      else
        cells.each do |c|
          c.cannot_assign_except(numbers)
        end
      end
    end
    
    def igeta_2 (x, b12, b34, cells, simulation=nil)
      if simulation
        b34.find{|b| b.cannot_assign(x, b12, simulation)}
      else
        b34.each do |b|
          b.cannot_assign(x, b12)
        end
      end
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
      rules.each do |rule|
        applicable = find_applicable_rule_instances(rule)
        return applicable if !applicable.empty?
      end
      []
    end
    
    def find_applicable_rule_instances (rule)
      case rule
      when :single_number
        @cell.collect{|c| c.find_single_number}.compact
      when :single_cell
        @block.collect{|b| b.find_single_cell}.flatten
      when :single_block
        @block.collect{|b| b.find_single_block}.flatten
      when :reserve_2_cells
        @block.collect{|b| b.find_reserve_n_cells(2)}.flatten
      when :reserve_3_cells
        @block.collect{|b| b.find_reserve_n_cells(3)}.flatten
      when :reserve_2_numbers
        @block.collect{|b| b.find_reserve_n_numbers(2)}.flatten
      when :reserve_3_numbers
        @block.collect{|b| b.find_reserve_n_numbers(3)}.flatten
      when :igeta_2
        self.find_igeta_2()
      else
        raise("#{rule} is not implemented")
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
    
    def find_igeta_2 ()
      (1..9).collect{|x| find_igeta_2_sub(@block, x)}.flatten
    end
    
    def find_igeta_2_sub (block, x)
      block.collect{|b| [b, b.possible_cells(x)]}.select{|y| y[1].length == 2}.combination(2).collect{|a, b|
        if (a[1] - b[1]).empty?
          nil
        elsif (b3 = common_block(a[1][0], b[1][0])) && (b4 = common_block(a[1][1], b[1][1]))
          Rule.new(:igeta_2, x, [a[0], b[0]], [b3, b4], a[1] + b[1]).effective?
        elsif (b3 = common_block(a[1][0], b[1][1])) && (b4 = common_block(a[1][1], b[1][0]))
          Rule.new(:igeta_2, x, [a[0], b[0]], [b3, b4], a[1] + b[1]).effective?
        else
          nil
        end
      }.compact
    end
    
    def common_block (c1, c2)
      (c1 != c2 && !(b = (c1.block & c2.block)).empty?) ? b[0] : nil
    end
  end
end
