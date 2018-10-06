def print_grid (grid, pad=" ")
  print (0..8).collect{|i| grid[9*i, 9].collect{|v| v || '.'}.join('')}.join(pad), "\n"
end

