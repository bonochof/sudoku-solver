ARGF.each do |line|
  line.chomp!
  print_grid(solve(make_grid(line.gsub(/\s/, ''))))
end

