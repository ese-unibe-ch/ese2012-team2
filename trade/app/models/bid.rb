module Models
  class Bid
    attr_accessor :bid_placed_by, :max_bid

    def initialize
      bid_placed_by = nil
      max_bid = 0
    end

    # saves the new bid for the auction
    def self.new_bid(user, max_bid)
      bid = Bid.new()
      bid.bid_placed_by = user
      bid.max_bid = max_bid
      return bid
    end

<<<<<<< HEAD
  def rise_bid(increment)
    max_bid = max_bid + increment unless increment <= 0
=======
    # raises the bid by the increment
    def raise_bid(increment)
      max_bid = max_bid + increment unless increment <= 0
    end
>>>>>>> 9b515c1ebb72a513b440ec50b636dd9fbee07b04
  end
end