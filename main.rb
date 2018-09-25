require "./print_grid.rb"
require "./make_grid.rb"

ARGF.each do |line|
  line.chomp!
  print_grid(solve(make_grid(line.gsub(/\s/, ''))))
end

