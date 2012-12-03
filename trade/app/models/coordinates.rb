require 'net/http'
require 'json/pure'
class Coordinates
  attr_accessor :lat, :lng

  def self.by_address(street, number, postal_code, city, country)
    response = Net::HTTP.get(URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{street}+#{number},#{postal_code}+#{city},#{country}&sensor=false"))
    data = JSON.parse(response)
    results = data["results"]

    geometry = results[0]["geometry"]
    coords = geometry["location"]
    lat = coords["lat"]
    lng = coords["lng"]
    self.new(lat,lng)
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
    a = Math::sin((lat1-lat2)/2)**2 + Math::cos(lat1)*Math::cos(lat2)*Math::sin((lng1-lng2)/2)**2
    dist = 6378.388 * 2*Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
  end
end
