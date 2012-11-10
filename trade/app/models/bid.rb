module Models
  class Bid
    attr_accessor :bid_placed_by, :max_bid

    def initialize
      self.bid_placed_by = nil
      self.max_bid = 0
    end

    # saves the new bid for the auction
    def self.new_bid(user, max_bid)
      bid = Bid.new()
      bid.bid_placed_by = user
      bid.max_bid = max_bid
      return bid
    end

    # raises the bid by the increment
    def raise_bid(increment)
      max_bid = max_bid + increment unless increment <= 0
    end
  end
end
