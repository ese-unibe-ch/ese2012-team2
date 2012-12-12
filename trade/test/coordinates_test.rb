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
    assert(((@coord1.distance(@coord2)*100).round()).to_f/100 == 418.32)  #SH Only compare to ten meters => Round
  end

  def test_address_to_coords
    coords3 = Coordinates.by_address("Sidlerstrasse 5", 3012, "Bern","CH")

    assert(coords3.lat == 46.95134680)
    assert(coords3.lng == 7.43845670)
  end

end