require 'net/http'
require 'json/pure'
# This class represents a position on planet earth given by standard coordinates.
# This class can be created either direct from coordinates or by a specific address
class Coordinates
  attr_accessor :lat, :lng

  # creates a Coordinates object out of the given address
  # raises an error when the address is not valid
  def self.by_address(street, postal_code, city, country)
    begin

    street =URI.escape(street)
    city =URI.escape(city)
    country =URI.escape(country)
    puts(street)
    response = Net::HTTP.get(URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{street},#{postal_code}+#{city},#{country}&sensor=false"))

    data = JSON.parse(response)
    results = data["results"]
    geometry = results[0]["geometry"]
    coords = geometry["location"]
    lat = coords["lat"]
    lng = coords["lng"]
    self.new(lat,lng)
    rescue
      raise TradeException, "Invalid address"
    end
  end

  def self.by_coords(lat,lng)
    self.new(lat,lng)
  end

  def initialize(lat,lng)
    @lat = lat
    @lng = lng
  end

  def distance(other_coordinates)
    lat1 = @lat * Math::PI / 180
    lat2 =  other_coordinates.lat * Math::PI / 180
    lng1 = @lng * Math::PI / 180
    lng2 = other_coordinates.lng * Math::PI / 180
    return Integer::MAX if lat1.nil? or lat2.nil? or lng1.nil? or lng2.nil?
    a = Math::sin((lat1-lat2)/2)**2 + Math::cos(lat1)*Math::cos(lat2)*Math::sin((lng1-lng2)/2)**2
    dist = 6378.388 * 2*Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
  end
end