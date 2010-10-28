#!/bin/env ruby

class Side
  class Cell
    def initialize
      @carved = nil

      @left = nil
      @right = nil
      @up = nil
      @down = nil
    end

    attr_accessor :left
    attr_accessor :right
    attr_accessor :up
    attr_accessor :down

    def carved?
      return @carved
    end

    def carve
      @carved = true
      self
    end

    def unmade?
      puts "unmade?"
      p self

      return true if sourrunded_by >= 3
      return nil
    end

    def sourrunded_by
      no = 0
      no += 1 if @left and not @left.carved?
      no += 1 if @right and not @right.carved?
      no += 1 if @up and not @up.carved?
      no += 1 if @down and not @down.carved?

      no += 1 unless @left
      no += 1 unless @right
      no += 1 unless @up
      no += 1 unless @down
      return no
    end

    def inspect
      out = "Cell (sourrunded_by #{sourrunded_by} walls):\n"
      out << "  #{up and up.to_s or "00"}  \n"
      out << "#{left and left.to_s or "00"}#{to_s}#{right and right.to_s or "00"}\n"
      out << "  #{down and down.to_s or "00"}  \n"
      out
    end

    def to_s
      return "  " if carved? 
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

class RecursiveBacktracker
  class Dirs
    def initialize
      @dirs = [:left, :right, :up, :down]
    end

    def rand
      return nil if @dirs.empty?
      dir = @dirs[Kernel.rand(@dirs.length)]
      @dirs.delete(dir)
      dir
    end

    def to_s
      p @dirs
    end
  end

  def initialize(cell)
    stack = []

    cell.carve
    stack << cell

    until stack.empty?
      loop do
        next_cell = find_move(cell) or break

        next_cell.carve
        stack << cell

        cell = next_cell
      end

      cell = stack.pop
    end
  end

  def find_move(cell)
    dirs = Dirs.new
    puts "finding move"
    loop do
      dir = dirs.rand or break

      puts "trying dir: #{dir}"

      c = cell.send(dir)
      puts "c: '#{c}'"
      next unless c

      puts "carved? #{c.carved?.inspect}"
      next if c.carved?

      puts "unmade? #{c.unmade?.inspect}"
      next unless c.unmade?

      puts "found move to #{c}"
      return c
    end

    puts "move not found"
    return nil
  end

  def cell_in(dir)
    c.send(dir)
  end
end

s1 = Side.new(1, 40)

puts s1

puts s1.cell(10,0)
puts s1.cell(0,10)
puts s1.cell(0,0)

begin
  RecursiveBacktracker.new(s1.cell(3, 0))
ensure
  puts s1
end


