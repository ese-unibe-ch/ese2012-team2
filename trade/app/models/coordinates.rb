require 'net/http'
class Coordinates
  attr_accessor :lat, :lng

  def initialize(lat,lng)
    @lat = lat
    @lng = lng
  end

  def distance(other_coordinates)
    other_lat = other_coordinates.lat
    other_lng = other_coordinates.lng
    dist = 6378.388 * Math::acos(Math::sin(lat) * Math::sin(other_lat) + Math::cos(lat) * Math::cos(other_lat) * Math::cos(other_lng - lng))    #TODO correct formula
  end



    def self.get_coords_by_address(street, number, postal_code, city, country)
      response = Net::HTTP.get(URI.parse("http:///maps/api/geocode/json?address=#{street}+#{number},#{postal_code}+#{city},#{country}&sensor=false"))
    end
end