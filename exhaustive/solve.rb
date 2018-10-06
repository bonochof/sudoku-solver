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
      1.upto(9) do |v|
        grid[p] = v
        if no_violation?(grid, p) && solve_sub(grid, p+1)
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

def no_violation? (grid, i, j)
  block_is_ok?(row(grid, p)) &&
  block_is_ok?(column(grid, p)) &&
  block_is_ok?(square(grid, p))
end

def block_is_ok? (block)
  unique?(block.compact)
end

def unique? (list)
  list.length == list.uniq.length
end

