#!/bin/env ruby

class Side
  class BorderCell
    def initialize(neighbor)
      @neighbor = neighbor
    end

    def border?
      return true
    end

    def carved?
      return false
    end

    def carve
      raise "cannot carve border cell"
    end

    def unmade?
      return true
    end

    def neighbors_carved
      no = 0
      no += 1 if @neighbor.carved?
      return no
    end

    def to_s
      "##"
    end

    def inspect
      self.class.name
    end
  end

  class Cell
    def initialize
      @carved = nil

      @left = BorderCell.new(self)
      @right = BorderCell.new(self)
      @up = BorderCell.new(self)
      @down = BorderCell.new(self)
    end

    attr_accessor :left
    attr_accessor :right
    attr_accessor :up
    attr_accessor :down

    def border?
      return false
    end

    def carved?
      return @carved
    end

    def carve
      @carved = true
      self
    end

    def unmade?
      return true if neighbors_carved <= 1
      return false
    end

    def neighbors_carved
      no = 0
      no += 1 if @left.carved?
      no += 1 if @right.carved?
      no += 1 if @up.carved?
      no += 1 if @down.carved?
      return no
    end

    def inspect
      out = "#{self.class.name} (neighbors_carved #{neighbors_carved} walls):\n"
      out << "  #{up.to_s or "00"}  \n"
      out << "#{left.to_s or "00"}#{to_s}#{right.to_s or "00"}\n"
      out << "  #{down.to_s or "00"}  \n"
      out
    end

    def to_s
      return ".." if carved? 
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
        cell.left = (cell(col_no - 1, row_no) or BorderCell.new(cell))
        cell.right = (cell(col_no + 1, row_no) or BorderCell.new(cell))
        cell.up = (cell(col_no, row_no - 1) or BorderCell.new(cell))
        cell.down = (cell(col_no, row_no + 1) or BorderCell.new(cell))
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
      return false if @dirs.empty?
      dir = @dirs[Kernel.rand(@dirs.length)]
      @dirs.delete(dir)
      dir
    end

    def to_s
      p @dirs
    end
  end

  def initialize(seed, cell)
    Kernel.srand(seed)

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
      p c
      next unless c

      next if c.border?
      next if c.carved?
      next unless c.unmade?

      puts "found move to"
      return c
    end

    puts "move not found"
    return false
  end

  def cell_in(dir)
    c.send(dir)
  end
end

s1 = Side.new(1, 40)

puts s1

begin
  RecursiveBacktracker.new(1, s1.cell(3, 0))
ensure
  puts s1
end


