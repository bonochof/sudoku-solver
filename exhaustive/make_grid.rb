def make_grid (string)
  string.split(//).collect{|c| c == "." ? nil : c.to_i}
end

