# frozen_string_literal: true

require 'json'

def search_closest(my_position, cell_positions)
  # Goal is to find the closet cell and go toward them
  # First, we need to compute distance toward every other cell
  # Secondly, we need to find the smallest one
  # We can do both at the same time
  # returns {key: index, distance: the distance}
  answer = {}
  cell_positions.each do |item|
    distance = compute_distance(my_position, item['position'])
    next unless !answer['key'] || distance < answer['distance']

    answer['distance'] = distance
    answer['key'] = item['key']
    answer['position'] = item['position']
  end
  answer
end

def search_farthest(my_position, cell_positions)
  answer = {}
  cell_positions.each do |item|
    distance = compute_distance(my_position, item['position'])
    next unless !answer['key'] || distance > answer['distance']

    answer['distance'] = distance
    answer['key'] = item['key']
    answer['position'] = item['position']
  end
  answer
end

def n_closest_method(my_position, cell_positions)
  # the goal here is to get the next best cell, which is the one with the closest n-next cells
  # returns the next cell to eat, which is the one with N cell closer
  N = 2
  # constructing an array of [{positions: [1, 442, 111], total_distance: 4442}]
  arr = cell_positions.map do |cell|
    res = {}
    N.times do |i|
      ans = search_closest(cell, cell_positions)
    end

  end

end

def go_to_cell_while_eating(start_cell, end_cell, cell_positions)
  # here we try an algorithm to go from A to B while eating the closest, in a direction
  # so next cell needs to be weighted by distance, not only to current_position, but to end_cell too

end

def gravity_method(my_position, cell_positions)
  # The goal here is to calculate the gravity of each cell
  # gravity is: F = G * (m1 * m2) / d²
  # here it could be: Ftot = SUM(2/D²) between this cell and each cell
  # we have then a vectorial field
  # in the first approach, we could simply go toward the field with the most gravity, and then take all the closest
  # so: 1-compute the gravity field  /  2 - go toward the highest gravity cell  /  3 - take all the closest
  # Next step would be to re-compute dynamically the vectorial field, and have an algorithm to choose between staying here to eat the closest or go there
  # Maybe eating the closest is not the best strategy neither: calculation of chains of N-closest (apparently limited to 4-5 by computer limitations)
  answer = {}
  if cell_positions.length == 20_000
    gravity_field = parse_gravity_file(GRAVITY_PATH)
    puts gravity_field.last, gravity_field.last.is_a?(String)
    key = gravity_field.max_by { |k| k['gravity'] }['key']
    start_point = find_cell_by_key(key, cell_positions)
    puts 'key', key, 'start_point', start_point
    answer = { 'key' => key, 'position' => start_point['position'], 'distance' => compute_distance(my_position, start_point['position']) }
  else
    answer = search_closest(my_position, cell_positions)
  end
  answer
end

def find_cell_by_key(key, cells)
  # returns the whole cell corresponding to the key
  cells.find { |f| f['key'] == key }
end

def parse_gravity_file(path)
  # parses the gravity file and returns an array of objects
  data_hash = JSON.parse(File.read(path))
end

def compute_gravity_field(cell_positions)
  # adds to each cell a gravity number, which is the sum of all gravity forces applied to this cell
  gravity_field = cell_positions.map do |cell|
    compute_cell_gravity(cell, cell_positions)
  end
  File.open('gravity_field.json', 'w+') do |f|
    f.write(gravity_field.to_json)
  end
end

def compute_cell_gravity(cell, cell_positions)
  # compute cell gravity and returns the cell object with gravity
  cell['gravity'] = 0
  cell_positions.each do |item|
    if cell['key'] != item['key']
      cell['gravity'] += (2 / compute_distance(cell['position'], item['position'])**2)
    end
  end
  cell
end

def yuliia_method(my_position, cell_positions)
  # first, go to the farthest
  # then to the closest ones
  answer = if cell_positions.length == 20_000
             search_farthest(my_position, cell_positions)
           else
             search_closest(my_position, cell_positions)
           end
  answer
end

def random(my_position, cell_positions)
  # next point is random
  cell = cell_positions.sample
  { 'distance' => compute_distance(my_position, cell['position']), 'key' => cell['key'], 'position': cell['position'] }
end

def get_next_move(my_position, cell_positions)
  # to try different algorithms
  # search_closest(my_position, cell_positions)
  # random(my_position, cell_positions)
  # yuliia_method(my_position, cell_positions)
  gravity_method(my_position, cell_positions)
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
    current_position = next_move['position']
    total_distance += next_move['distance']
    moves << next_move['key']
    # need to remove the move from the parsed_data
    parsed_data.reject! { |item| item['key'] == next_move['key'] }
  end
  moves.pop

  # needs to write the output in a file
  File.open('PE_answer.txt', 'w+') do |f|
    f.puts(moves)
  end
end

MAX_TIME = 100_000
PATH = './input_2.txt'
GRAVITY_PATH = './gravity_field.json'

main
