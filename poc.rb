require 'io/console'
class Babel
  attr_reader :tower, :brick_width
  attr_accessor :index, :rewards

  def initialize
    @tower = []
    @rewards = []
    @index = 0
    @brick_width = 11.0
  end

  def check_balance
    cg = 0
    collapse_index = 0
    @tower.each_with_index do |brick, index|
      if index == 0
        cg = brick.offset
      else
        if (cg - brick.offset).abs > @brick_width / 2
          collapse_index = index
          break if index == 1 # jump out the balance check if it's the topest brick and not in the range
        end
        cg = (cg * index + brick.offset).to_f / (index + 1)
      end
    end
    collapse!(collapse_index) if collapse_index > 0
  end

  def add_brick
    @index += 1
    pre_offset = @tower.first ? @tower.first.offset : 0
    @tower.unshift Brick.new(@index, pre_offset)
    check_balance
  end

  def collapse!(index)
    #puts '~' * 16 + 'collapsed' + '~' * 15
    #puts self.to_s
    #puts '~' * 40
    @rewards << @tower.shift(index)
  end

  def to_s
    str = @tower.join("\n") + "\n"
    #str += "collapsed: " + @rewards.collect{|arr| arr.flatten.map(&:id).join(",") }.join(" | ") if @rewards.size > 0
    str
  end
end

class Brick
  attr_reader :offset, :id

  def initialize(id, pre_offset = 0)
    @eth_hold = 1
    @id = id.to_s
    set_position(pre_offset)
  end

  def set_position(pre_offset)
    @offset = (0.5 - rand) * 5 + pre_offset
  end

  def to_s
    @id.rjust(4, ' ') + ' ' * (50 + @offset) + '=' * 11
  end
end

babel = Babel.new
height = 0
(1..1000).each do
  babel.add_brick
  #puts babel.to_s
  #puts '-' * 80
  height = babel.tower.length if height < babel.tower.length
  #STDIN.getch
end
puts babel.to_s

puts height
puts babel.tower.length

stats = babel.rewards.map(&:length).group_by{|i| i % 1000}
stats.each_pair{|k, v| stats[k] = v.length}
puts stats.sort_by{|arr| arr[0]}.map{|arr| arr.join('=>')}.join(', ')
