require 'optparse'
require "./sudoku.rb"

param = ARGV.getopts('vr:')
verbose = param['v']
Rules = [:single_cell, :single_number]
rules = (!param['r'] ? Rules : Rules[0, param['r'].to_i])

ARGF.each do |line|
  line.cnomp!
  next if line =~ /^\s*$/
  print line, "\n"
  
  q = line.split(/\t/)[0]
  grid = Sudoku::Grid.new(q.gsub(/\s/, ''))
  grid.solve(rules, verbose)
  grid.show_result()
end
