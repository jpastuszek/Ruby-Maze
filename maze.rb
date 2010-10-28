#!/bin/env ruby

class Side
  class Cell
    def initialize
      @open = false

      @left = nil
      @right = nil
      @up = nil
      @down = nil
    end

    attr_accessor :left
    attr_accessor :right
    attr_accessor :up
    attr_accessor :down

    def open?
      return @open
    end

    def open
      @open = true
      self
    end

    def to_s
      return "  " if open? 
      return "[]"
    end
  end

  def initialize(name, size)
    @name = name

    @maze = []

    # populate
    size.times do
      row = []
      size.times do
        row << Cell.new
      end
      @maze << row
    end

    # link
    @maze.each_with_index do |row, row_no|
      row.each_with_index do |cell, col_no|
        cell.left = cell(col_no - 1, row_no)
        cell.right = cell(col_no + 1, row_no)
        cell.up = cell(col_no, row_no - 1)
        cell.down = cell(col_no, row_no + 1)
      end
    end
  end

  def cell(x, y)
    return nil if x < 0 or y < 0
    row = @maze[y] or return nil
    row[x] or return nil
  end

  def to_s
    out = "Side #{@name}:\n"

    out << "  "
    @maze[0].each_with_index do |cell, i|
      out << "#{i} "
    end
    out << "\n"

    @maze.each_with_index do |row, i|
      out << "#{i} "
      row.each do |cell|
        out << cell.to_s
      end
      out << "\n"
    end
    out
  end
end

s1 = Side.new(1, 7)

puts s1

puts s1.cell(10,0)
puts s1.cell(0,10)
puts s1.cell(0,0)

puts s1.cell(0,0).open.right.open.right.open.down.open.right.open

puts s1

