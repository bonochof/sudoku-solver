def print_grid (grid)
  print grid.collect{|line| line.collect{|v| (v || '.')}.join('')}.join("\n"), "\n"
end

