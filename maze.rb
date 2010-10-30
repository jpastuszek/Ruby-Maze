#!/bin/env ruby

require 'cairo'

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
      @carved = false
      @marked = false

      @left = nil
      @right = nil
      @up = nil
      @down = nil
    end

    attr_accessor :left
    attr_accessor :right
    attr_accessor :up
    attr_accessor :down

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

    def marked?
      return @marked
    end

    def mark
      #@marked = true
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
      if marked?
        return "**" if carved? 
        return "<>"
      end 
      return "[]" if carved? 
      return "  "
    end
  end

  attr_reader :size

  def initialize(name, size)
    @name = name
    @size = size

    @maze = []

    populate

    yield self

    link
  end

  def populate
    @size.times do
      row = []
      @size.times do
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
    set_cell(x, y, Cell.new)
  end

  def del_cell(x, y)
    set_cell(x, y, nil)
  end

  def set_cell(x, y, c)
    raise "negative space index" if x < 0 or y < 0 

    row = @maze[y] or raise "out of rows"
    raise "out of colls" if x >= row.length

    row[x] = c
  end

  def to_s
    out = "#{self.class.name} #{@name}:\n"

    out << "  "
    @maze[0].each_with_index do |cell, i|
      out << "%-2d" % i
    end
    out << "\n"

    @maze.each_with_index do |row, i|
      out << "%2d" % i
      row.each do |cell|
        if cell
          out << cell.to_s
        else
          out << "##"
        end
      end
      out << "\n"
    end
    out
  end
end

class SpaceRenderer
  def initialize(space, format = Cairo::FORMAT_ARGB32)
    @width = space.size
    @height = space.size

    @surface = Cairo::ImageSurface.new(@format, @width, @height)
    @context = Cairo::Context.new(@surface)

    @context.set_source_rgb(1, 1, 1)
    @context.rectangle(0, 0, @width, @height)
    @context.fill

    set_color(1, 0, 0)
    set_pixel(1, 10)

    @width.times do |x|
      @height.times do |y|
        c = space.cell(x, y)
        next unless c
        if c.carved?
          set_color(0, 0, 0)
        else
          set_color(1, 0, 0)
        end

        set_pixel(x, y)
      end
    end
  end

  def set_color(r, g, b)
    @context.set_source_rgb(r, g, b)
  end

  def set_pixel(x, y)
    @context.rectangle(x, y, 1, 1)
    @context.fill
  end

  def write(file)
    @surface.write_to_png(file)
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

def gen_side(space, x, y, size)
  size.times do |row|
    size.times do |col|
      space.make_cell(x + row, y + col)
    end
  end

  space.del_cell(x + size / 2, y + 0)
  space.del_cell(x + size / 2, y + size - 1)

  space.del_cell(x + 0, y + size / 2)
  space.del_cell(x + size - 1, y + size / 2)
end

def hor_link(left, right)
  left.right = right
  right.left = left

  right.mark
  left.mark
end

def vert_link(up, down)
  up.down = down
  down.up = up

  up.mark
  down.mark
end

def up_left_link(up, left)
  up.up = left
  left.left = up

  up.mark
  left.mark
end

def down_left_link(down, left)
  down.down = left
  left.left = down

  down.mark
  left.mark
end

def right_down_link(right, down)
  right.right = down
  down.down = right

  right.mark
  down.mark
end

def right_up_link(right, up)
  right.right = up
  up.up = right

  right.mark
  up.mark
end

def down_link(c1, c2)
  c1.down = c2
  c2.down = c1

  c1.mark
  c2.mark
end

def up_link(c1, c2)
  c1.up = c2
  c2.up = c1

  c1.mark
  c2.mark
end

def gen(seed)
  s1 = Space.new(seed, 31) do |space|
    gen_side(space, 8, 0, 7)
    gen_side(space, 0, 8, 7)
    gen_side(space, 8, 8, 7)
    gen_side(space, 16, 8, 7)
    gen_side(space, 24, 8, 7)
    gen_side(space, 8, 16, 7)

  end

  hor_link(s1.cell(5, 11), s1.cell(9, 11))
  hor_link(s1.cell(13, 11), s1.cell(17, 11))
  hor_link(s1.cell(21, 11), s1.cell(25, 11))
  hor_link(s1.cell(29, 11), s1.cell(1, 11))

  vert_link(s1.cell(11, 5), s1.cell(11, 9))
  vert_link(s1.cell(11, 13), s1.cell(11, 17))

  down_link(s1.cell(11, 21), s1.cell(27, 13))
  up_link(s1.cell(11, 1), s1.cell(27, 9))

  up_left_link(s1.cell(3, 9), s1.cell(9, 3))

  down_left_link(s1.cell(3, 13), s1.cell(9, 19))

  right_down_link(s1.cell(13, 19), s1.cell(19, 13))
  right_up_link(s1.cell(13, 3), s1.cell(19, 9))

  #puts s1
  begin
    RecursiveBacktracker.new(seed, s1.cell(11, 11))
  ensure
    puts s1
  end

  s1
end

1.times do |seed|
  s = gen(seed)
  SpaceRenderer.new(s).write("sourface_#{seed}.png")
end

