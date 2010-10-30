#!/bin/env ruby

class Space
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

      @left = nil
      @right = nil
      @up = nil
      @down = nil
    end

    attr_reader :left
    attr_reader :right
    attr_reader :up
    attr_reader :down

    def link(left, right, up, down)
      @left = (left or BorderCell.new(self))
      @right = (right or BorderCell.new(self))
      @up = (up or BorderCell.new(self))
      @down = (down or BorderCell.new(self))
    end

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
      return "UnlikedCell" unless @left and @right and @up and @down
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

    populate(size)

    yield self

    link
  end

  def populate(size)
    size.times do
      row = []
      size.times do
        row << nil
      end
      @maze << row
    end
  end

  def link
    @maze.each_with_index do |row, row_no|
      row.each_with_index do |cell, col_no|
        if cell and not cell.border?
          left = cell(col_no - 1, row_no)
          right = cell(col_no + 1, row_no)
          up = cell(col_no, row_no - 1)
          down = cell(col_no, row_no + 1)

          cell.link(left, right, up, down)
        end
      end
    end
  end

  def cell(x, y)
    return nil if x < 0 or y < 0
    row = @maze[y] or return nil
    row[x] or return nil
  end

  def make_cell(x, y)
    raise "negative space index" if x < 0 or y < 0 

    row = @maze[y] or raise "out of rows"
    raise "out of colls" if x >= row.length

    row[x] = Cell.new
  end

  def to_s
    out = "#{self.class.name} #{@name}:\n"

    out << "  "
    @maze[0].each_with_index do |cell, i|
      out << "#{i} "
    end
    out << "\n"

    @maze.each_with_index do |row, i|
      out << "#{i} "
      row.each do |cell|
        if cell
          out << cell.to_s
        else
          out << "  "
        end
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
    raise "nil start cell" unless cell
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
    #puts "finding move"
    loop do
      dir = dirs.rand or break

      #puts "trying dir: #{dir}"

      c = cell.send(dir)
      #p c
      next unless c

      next if c.border?
      next if c.carved?
      next unless c.unmade?

      #puts "found move to"
      return c
    end

    #puts "move not found"
    return false
  end

  def cell_in(dir)
    c.send(dir)
  end
end

s1 = Space.new(1, 40) do |m|
  20.times do |row|
    20.times do |col|
      m.make_cell(row + 10, col + 10)
    end
  end
end

puts s1

begin
  RecursiveBacktracker.new(1, s1.cell(10, 10))
ensure
  puts s1
end


