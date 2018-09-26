def make_grid (string)
  (0..8).collect{|i| string[i*9, 9].split(//).collect{|c| c == "." ? nil : c.to_i}}
end

