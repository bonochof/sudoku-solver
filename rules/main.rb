require 'optparse'
require "./sudoku.rb"

param = ARGV.getopts('vr:')
verbose = param['v']
Rules = [:single_cell, :single_number, :single_block,
         :reserve_2_cells, :reserve_2_numbers,
         :reserve_3_cells, :reserve_3_numbers,
         :igeta_2]
rules = (!param['r'] ? Rules : Rules[0, param['r'].to_i])

ARGF.each do |line|
  line.chomp!
  next if line =~ /^\s*$/
  print line, "\n"
  
  q = line.split(/\t/)[0]
  grid = Sudoku::Grid.new(q.gsub(/\s/, ''))
  grid.solve(rules, verbose)
  grid.show_result()
end
