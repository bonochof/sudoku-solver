def make_grid (string)
  grid = 9.times.collect{ Array.new(9, nil) }
  0.upto(8) do |i|
    0.upto(8) do |j|
      grid[i][j] = (string[i*9+j] == "." ? nil : string[i*9+j].to_i)
    end
  end
  grid
end

