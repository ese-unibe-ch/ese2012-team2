require "test/unit"
Bundler.require
require_relative '../app/models/coordinates'

class CoordinatesTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @coord1 = Coordinates.new(50.11222,8.68194)
    @coord2 = Coordinates.new(52.52222,13.29750)
  end

  def test_distance
    puts @coord1.distance(@coord2)
    assert(@coord1.distance(@coord2), 418.34)
  end

end