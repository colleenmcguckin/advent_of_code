require_relative '../puzzle_input.rb'

class CubeConundrum
  include PuzzleInput
  
  attr_reader :possible_games, :games
  
  CubeCount = Struct.new(:count, :color)

  MASTER_CUBE_COUNTS = {
    "red" => 12, 
    "green" => 13, 
    "blue" => 14
  }

  def self.solve!
    puts "Cube Conundrum"
    puts ">>> Determine which games would have been possible if the bag had been loaded with only 12 red cubes, 13 green cubes, and 14 blue cubes. What is the sum of the IDs of those games?"
    puts self.new('02_cube_conundrum/input.txt').possible_games.map(&:id).sum
    puts ">>> For each game, find the minimum set of cubes that must have been present. What is the sum of the power of these sets?"
    puts self.new('02_cube_conundrum/input.txt').games.map(&:highest_draws).map { |highest_draw| highest_draw.values.reduce(:*) }.sum
  end

  def initialize(game_input)
    @puzzle_input = load_from_text_file(game_input)
    @cube_check = MASTER_CUBE_COUNTS.map { |cube_set| [cube_set.first, cube_set.last] }.to_h
    @games = @puzzle_input.map do |game_input|
      Game.new(game_input)
    end
    @possible_games, @impossible_games = check_games!
  end

  private

  def check_games!
    @games.each { |game| check_game(game) }
    @games.partition { |game| game.possible? }
  end

  def check_game(game)
    possible = game.highest_draws.all? do |color, count|
      count.to_i <= @cube_check[color].to_i
    end
    game.mark_possible! if possible
  end
end

class Game
  attr_reader :id, :highest_draws

  # game_input should be a string.
  # "Game 11: 4 blue, 11 green, 6 red; 12 red, 1 blue, 5 green; 7 red, 1 blue"
  def initialize(game_input)
    @raw_inputs = game_input.split(":")
    @id = @raw_inputs.first.delete!("Game ").to_i
    @draws = parse_results(@raw_inputs.last)
    @possible = false
    @highest_draws = highest_draws
  end

  def parse_results(results)
    results.split("; ").map do |draw|
      draws = draw.split(", ").map do |cubeset|
        count, color = cubeset.split(" ")
        CubeConundrum::CubeCount.new(count.to_i, color)
      end.flatten(1)
    end
  end

  def highest_draws
    highest_draws = {}
    @draws.flatten.group_by { |draw| draw.color }.map do |color, cubes|
      highest_draws[color] = cubes.max_by(&:count).count
    end
    highest_draws
  end

  def mark_possible!
    @possible = true
  end

  def possible?
    !!@possible
  end
end