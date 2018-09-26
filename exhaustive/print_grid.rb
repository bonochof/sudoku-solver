def print_grid (grid, pad=" ")
  print grid.collect{|line| line.collect{|v| (v || '.')}.join('')}.join(pad), "\n"
end

