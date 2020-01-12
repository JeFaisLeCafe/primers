# frozen_string_literal: true

def search_closest(my_position, cell_positions)
  # Goal is to find the closet cell and go toward them
  # First, we need to compute distance toward every other cell
  # Secondly, we need to find the smallest one
  # We can do both at the same time
  # returns {key: index, distance: the distance}
  answer = {}
  cell_positions.each do |item|
    distance = compute_distance(my_position, item['position'])
    if !answer['key'] || distance < answer['distance']
      answer['distance'] = distance
      answer['key'] = item['key']
    end
  end
  answer
end

def random(my_position, cell_positions)
  # next point is random
  cell = cell_positions.sample
  { 'distance' => compute_distance(my_position, cell['position']), 'key' => cell['key'] }
end

def get_next_move(my_position, cell_positions)
  # to try different algorithms
  # search_closest(my_position, cell_positions)
  random(my_position, cell_positions)
end

def compute_distance(position_1, position_2)
  Math.sqrt((Integer(position_2.x) - Integer(position_1.x))**2 + (Integer(position_2.y) - Integer(position_1.y))**2)
end

class Position
  attr_accessor :x, :y
  def initialize(x = 0, y = 0)
    @x = x
    @y = y
  end
end

def parse_file(path)
  # parses the file and returns an array
  data = []
  File.open(path).each do |line|
    txt_arr = line.split(',').map(&:strip)
    data << { 'key' => txt_arr[0], 'position' => Position.new(txt_arr[1], txt_arr[2]) }
  end
  puts data.length
  data
end

def main
  # runs my algo
  # need to parse the file
  # then find the closest cell
  # then add the closest to my answer list
  # repeats without this index in the file
  # until "time runs out" ==> total distance > total time (first line)
  # removes last move and return array
  moves = []
  total_distance = 0
  current_position = Position.new
  parsed_data = parse_file(PATH)
  while total_distance < MAX_TIME
    next_move = get_next_move(current_position, parsed_data)
    total_distance += next_move['distance']
    moves << next_move['key']
    # need to remove the move from the parsed_data
    parsed_data.reject! { |item| item['key'] == next_move['key'] }
    puts 'total', total_distance, 'added', next_move
  end
  puts 'last', moves.last
  moves.pop
  puts 'last', moves.last
  puts total_distance

  # needs to write the output in a file
  File.open('PE_answer.txt', 'w+') do |f|
    f.puts(moves)
  end
end

MAX_TIME = 100_000
PATH = './input_2.txt'

main
