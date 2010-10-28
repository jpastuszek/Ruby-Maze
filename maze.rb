#!/bin/env ruby

class Side
  class Cell
    def initialize
      @open = false
    end

    def open?
      return @open
    end

    def open
      @open = true
    end

    def to_s
      return "  " if open? 
      return "[]"
    end
  end

  class Walker
    def initialize(maze, x, y)
      @maze = maze
      @cell = nil
      go_to(x, y)
    end

    def current
      @cell
    end

    def go_left
      go_to(@x - 1, @y)
    end

    def go_right
      go_to(@x + 1, @y)
    end

    def go_up
      go_to(@x, @y - 1)
    end

    def go_down
      go_to(@x, @y + 1)
    end

    def go_to(x, y)
      @cell = @maze.cell(x, y)
      @x = x
      @y = y
      @cell
    end

    def to_s
      "Walker: #{@x} #{@y}"
    end
  end

  def initialize(name, size)
    @name = name

    @maze = []

    size.times do
      row = []
      size.times do
        row << Cell.new
      end
      @maze << row
    end
  end

  def walk(from_x, from_y)
    Walker.new(self, from_x, from_y)
  end

  def cell(x, y)
    return nil if x < 0 or y < 0
    (row = @maze[y] and row[x]) or raise "out of maze at: #{x} #{y}"
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
w1 = s1.walk(0, 0)

puts s1, w1

#puts s1.cell(10,0)
#puts s1.cell(0,10)
#puts s1.cell(0,0)

w1.current.open
w1.go_right.open
w1.go_right.open
w1.go_right.open
w1.go_down.open

puts s1

