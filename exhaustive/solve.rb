def solve (grid)
  solve_sub(grid, 0)
  grid
end

def solve_sub (grid, p)
  if p > 80
    return true
  else
    i = p / 9
    j = p % 9
    if grid[i][j]
      solve_sub(grid, p+1)
    else
      1.upto(9) do |v|
        grid[i][j] = v
        if no_violation?(grid, i, j)
          if solve_sub(grid, p+1)
            return true
          end
        end
      end
      grid[i][j] = nil
      return false
    end
  end
end

def no_violation? (grid, i, j)
  block_is_ok?(grid[i]) &&
  block_is_ok?((0..8).collect{|k| grid[k][j]}) &&
  block_is_ok?((0..8).collect{|k| grid[3*(i/3)+(k/3)][3*(j/3)+(k%3)]})
end

def block_is_ok? (block)
  unique?(block.select{|v| v})
end

def unique? (list)
  list.length == list.uniq.length
end

