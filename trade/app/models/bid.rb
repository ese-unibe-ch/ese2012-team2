module Models
  class Bid
    attr_accessor  :bid_placed_by, :max_bid
  end

  def initialize
    bid_placed_by = nil
    max_bid = 0
  end

  def self.bid(user,max_bid)
    bid_placed_by = user
    max_bid = max_bid
  end

  def rise_bid(increment)
    max_bid = max_bid + increment unless increment <= 0
  end



end