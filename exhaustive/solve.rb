def solve (grid)
  solve_sub(grid, 0)
  grid
end

def solve_sub (grid, p)
  if p > 80
    return true
  else
    if grid[p]
      solve_sub(grid, p+1)
    else
      possible_numbers(grid, p).each do |v|
        grid[p] = v
        if solve_sub(grid, p+1)
            return true
        end
      end
      grid[p] = nil
      return false
    end
  end
end

def row (grid, p)
  grid[9*(p/9), 9]
end

def column (grid, p)
  (0..8).collect{|k| grid[9*k+p%9]}
end

def square (grid, p)
  (0..8).collect{|k| grid[9*(3*(p/9/3)+(k/3))+3*(p%9/3)+(k%3)]}
end

def possible_numbers (grid, p)
  (1..9).to_a - fixed_numbers(grid, p)
end

def fixed_numbers (grid, p)
  row(grid, p).compact |
  column(grid, p).compact |
  square(grid, p).compact
end

